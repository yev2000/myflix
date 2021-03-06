require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe UsersController do 
  describe "GET new" do
    it "shows new user template" do
      get :new
      expect(response).to render_template "new"
    end

    it "sets @user a fresh user" do
      get :new
      expect(assigns(:user)).to be_a(User)
      expect(assigns(:user).new_record?).to be true
    end
  end

  describe "GET show" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :show, id: 1 } }
    end

    context "logged in user" do
      before { set_current_user }

      context "valid user ID supplied" do
        before do
          @alice = Fabricate(:user)
          get :show, id: @alice.id
        end

        it("renders the show user template") { expect(response).to render_template "show" }
        
        it "sets @user to the user specified in the URL parameters" do
          expect(assigns(:user)).to eq(@alice)
        end

        it "sets @fresh_following if the user is not being followed by the current user" do
          expect(assigns(:fresh_following)).to be_a(Following)
          expect(assigns(:fresh_following).new_record?).to be true
        end
      end

      it "does not set @fresh_following if the user is already being followed by the current user" do
        leader = Fabricate(:user)
        Following.create(leader: leader, follower: spec_get_current_user)
        get :show, id: leader.id
        expect(assigns(:fresh_following)).to be_nil
      end

      it "does not set @fresh_following if the user is the current user" do
        get :show, id: spec_get_current_user.id
        expect(assigns(:fresh_following)).to be_nil
      end
      
      context "invalid user ID supplied" do
        before do
          alice = Fabricate(:user)
          get :show, id: User.last.id + 1
        end

        it("flashes a danger message") { expect_danger_flash }
        it("redirects to root path") { expect(response).to redirect_to root_path }
      end

    end # logged in user

  end # GET show

  describe "POST create" do  
    context "successful user creation" do
      before do
        the_created_user = Fabricate(:user)
        @user_creation = double("user creation", successful?: true, created_user: the_created_user)
        UserCreation.should_receive(:new).with(anything, anything).and_return(@user_creation)
      end

      context "without invitation" do
        it "delegates to UserCreation to create a user" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        end

        it "calls the successful? method of the UserCreation service" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          expect(@user_creation).to receive(:successful?)
          post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        end

        it "calls the created_user method of the UserCreation service" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          expect(@user_creation).to receive(:created_user)
          post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        end

        it "redirects to the home path" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
          expect(response).to redirect_to home_path
        end

        it "sets a successful flash" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
          expect_success_flash
        end

        it "logs user in, if user created" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
          expect(session[:userid]).to eq(@user_creation.created_user.id)
        end
      end

      context "with invitation" do      
        it "delegates to UserCreation to create a user" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", invitation_token: "abc", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        end

        it "calls the successful? method of the UserCreation service" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          expect(@user_creation).to receive(:successful?)
          post :create, { stripeToken: "123", invitation_token: "abc", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        end

        it "calls the created_user method of the UserCreation service" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          expect(@user_creation).to receive(:created_user)
          post :create, { stripeToken: "123", invitation_token: "abc", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        end

        it "redirects to the home path" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", invitation_token: "abc", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
          expect(response).to redirect_to home_path
        end

        it "sets a successful flash" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", invitation_token: "abc", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
          expect_success_flash
        end

        it "logs user in, if user created" do
          @user_creation.should_receive(:create_user).and_return(@user_creation)
          post :create, { stripeToken: "123", invitation_token: "abc", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
          expect(session[:userid]).to eq(@user_creation.created_user.id)
        end
      end
    end # successful creation

    context "password confirmation does not match password" do
      before do
        @user_creation = double("user creation")
        UserCreation.stub(:new).and_return(@user_creation)
      end

      it "does not delegate to UserCreation service" do
        expect(@user_creation).not_to receive(:create_user)
        post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "foo"} }
      end

      it "sets the @user instance variable to the email and username in the form" do
        post :create, { user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "foo"} }
        expect(assigns(:user).email).to eq("joe@company.com")
        expect(assigns(:user).fullname).to eq("joe smith")
      end

      it "renders the new template" do
        post :create, { user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "foo"} }
        expect(response).to render_template :new
      end     
    end # password mismatch

    context "unsuccessful user creation by service" do
      before do
        @user_creation = double("user creation", successful?: false, error_message: "ERROR")
        UserCreation.should_receive(:new).with(anything, anything).and_return(@user_creation)
      end

      it "delegates to UserCreation to create a user" do
        @user_creation.should_receive(:create_user).and_return(@user_creation)
        post :create, { stripeToken: "123", invitation_token: "abc", user: {email: "def", fullname: "ghi", password: "pass", password_confirm: "pass"} }
      end

      it "calls the successful? method of the UserCreation service" do
        @user_creation.should_receive(:create_user).and_return(@user_creation)
        expect(@user_creation).to receive(:successful?)
        post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
      end

      it "renders the new template" do
        @user_creation.should_receive(:create_user).and_return(@user_creation)
        post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        expect(response).to render_template :new
      end

      it "calls the error_message method of the user creation service" do
        @user_creation.should_receive(:create_user).and_return(@user_creation)
        expect(@user_creation).to receive(:error_message)
        post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
      end

      it "sets the danger flash" do
        @user_creation.should_receive(:create_user).and_return(@user_creation)
        post :create, { stripeToken: "123", user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }
        expect_danger_flash
      end
    end # unsuccessful user creation

  end # POST create

  describe "GET edit" do
    context "no logged in user" do
      it "redirects to the sign_in screen" do
        u = Fabricate(:user)
        expect(User.find(1)).not_to be_nil
        get :edit, id: 1
        expect(response).to redirect_to sign_in_path
      end
    end

    context "user logged in" do
      before do
        u = Fabricate(:user)
        session[:userid] = 1
      end

      it "redirects to the front path if no user identified by the ID exists" do
        get :edit, id: "2"
        expect(response).to redirect_to root_path
      end

      it "sets the @user instance variable to the id specified by the id parameter" do
        get :edit, id: "1"
        expect(assigns(:user)).to eq(User.first)
      end

      it "renders the edit template" do
        get :edit, id: "1"
        expect(response).to render_template :edit
      end
    end
  end # GET edit

  describe "POST update" do
    context "no logged in user" do
      it "redirects to the sign_in screen" do
        post :update, id: "1", user: {email: "a@b.c", fullname: "jane smith"}
        expect(response).to redirect_to sign_in_path
      end
    end
  
    context "logged in user" do
      before do
        u = Fabricate(:user, fullname: "jane smith")
        session[:userid] = 1
      end

      it "redirects to the front path if no user identified by the ID exists" do
        post :update, id: "2", user: {fullname: "joe smith"}
        expect(response).to redirect_to root_path
      end
      
      it "updates username if it was modified" do
        expect(User.first.fullname).to eq("jane smith")
        post :update, id: "1", user: {fullname: "joe smith"}
        expect(User.first.fullname).to eq("joe smith")
      end

      it "redirects to the show user page if successfully edited user" do
        post :update, id: "1", user: {fullname: "joe smith"}
        expect(response).to redirect_to user_path(User.find(1))
      end

      it "does not update password if password and password confirm don't match" do
        post :update, id: "1", user: {password: "aaaa", password_confirm: "bbbb" }
        expect(User.first.authenticate("aaaa")).to eq(false)
      end

      it "renders the edit screen if password and password confirm don't match" do
        post :update, id: "1", user: {password: "aaaa", password_confirm: "bbbb" }
        expect(response).to render_template :edit
      end

      it "renders the edit screen if user by email already exists" do
        user_1 = User.find(1)
        user_2 = Fabricate(:user)
        post :update, id: "2", user: {email: user_1.email}
        expect(User.find(2).email).not_to eq(user_1.email)
        expect(response).to render_template :edit
      end

      it "updates user password if password and password confirm match" do
        post :update, id: "1", user: {password: "QQQQaa", password_confirm: "QQQQaa" }
        u = User.first
        expect(u.authenticate("QQQQaa")).to eq(u)
      end

    end

  end # POST update
end
