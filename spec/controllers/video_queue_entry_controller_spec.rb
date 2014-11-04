require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe VideoQueueEntryController do

  describe "GET index" do
    context "no logged in user" do
      context "user_id parameter is supplied" do
        it_behaves_like("require_sign_in") { let(:action) { get :index, user_id: 1 } }
      end
  
      context "user_id is not supplied" do
        it_behaves_like("require_sign_in") { let(:action) { get :index } }
      end
    end # no logged in user

    context "logged in user" do
      let(:user) { Fabricate(:user) }
      before { set_current_user(user) }

      context "user_id parameter supplied" do
        context "user_id does not match current logged in user" do
          let(:user2) { Fabricate(:user) }
          before { get :index, user_id: user2.id }
          
          it("redirects to home path") { expect(response).to redirect_to home_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        end

        it "sets @user to the user specified by the user_id parameter" do
          user2 = Fabricate(:user)
          get :index, user_id: user2.id
          expect(assigns(:user)).to eq(user2)
        end

        context "no video queue entries for user" do
          before { get :index, user_id: user.id }

          it("sets @queue_entries to empty array") { expect(assigns(:queue_entries)).to eq([]) }
          it("renders index template") { expect(response).to render_template :index }
        end

        context "a video exists in the user's queue" do
          it "sets @queue_entries" do
            video = Fabricate(:video)
            vqe = Fabricate(:video_queue_entry, user: user, video: video)

            get :index, user_id: user.id
            expect(assigns(:queue_entries)).to eq([vqe])
          end

          it "sets @queue_entries to the queued videos, sorted by position" do
            vqe_array = []
            [1,2,3,4].each_with_index do |num, index|
              vqe_array << Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: 5 - index)
            end

            get :index, user_id: user.id

            expect(assigns(:queue_entries)).to eq(vqe_array.reverse)
          end

        end
      end # user ID explicitly supplied

      context "user_id is not supplied in params" do
        it("sets @user to the current user") do
          get :index
          expect(assigns(:user)).to eq(user)
        end

        context "no video queue entries for user" do
          before { get :index }

          it("sets @queue_entries to empty array") { expect(assigns(:queue_entries)).to eq([]) }
          it("renders index template") { expect(response).to render_template :index }
        end

        context "a video exists in the user's queue" do
          it "sets @queue_entries" do
            vqe = Fabricate(:video_queue_entry, user: user, video: Fabricate(:video))

            get :index
            expect(assigns(:queue_entries)).to eq([vqe])
          end
        end
      end # user id not supplied
    end # logged in user
  end # GET index

  describe "POST create" do
    before do
      Fabricate(:user)
      Fabricate(:video)
    end

    context "no logged in user" do
      context "user ID supplied in parameters" do
        it_behaves_like("require_sign_in") { let(:action) { post :create, user_id: 1, video_id: 1 } }
      end

      context "no user ID supplied in parameters" do
        it_behaves_like("require_sign_in") { let(:action) { post :create, video_id: 1 } }
      end
    end # no logged in user

    context "logged in user" do
      let(:user) { Fabricate(:user) }
      before { set_current_user(user) }

      context "user_id supplied in parameters" do
        context "user_id does not match current logged in user" do
          let(:user2) { Fabricate(:user) }
          before { post :create, user_id: user2.id, video_queue_entry: { user_id: user2.id, position: 1, video_id: 1 } }
          
          it("redirects to home path") { expect(response).to redirect_to home_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        end

        it "sets @user to the user specified by the ID" do
          user2 = Fabricate(:user)
          post :create, user_id: user2.id, video_queue_entry: { user_id: user2.id, position: 1, video_id: 1 }
          expect(assigns(:user)).to eq(user2)
        end

      end # user ID in parameters

      context "user_id not provided in parameters" do
        it "sets @user to the current user" do
          post :create, video_queue_entry: { position: 1, video_id: 1 }
          expect(assigns(:user)).to eq(user)
        end
      end

      context "valid inputs and user and video" do
        before { post :create, video_queue_entry: { position: 1, video_id: 1 } }

        it("adds a video entry to the users's queue") { expect(user.video_queue_entries.size).to eq(1) }
        it("adds the video specified by video_id as a queued video in the users's queue") { 
          expect(user.queued_videos).to include(Video.first) }
        it("redirects to the my_queue path") { expect(response).to redirect_to my_queue_path }
        it("sets a success flash message") { expect(flash[:success]).not_to be_nil }
      end

      context "omitted video field" do
        before { post :create, video_queue_entry: { position: 1 } }

        it("sets a danger flash message if video_id is omitted") { expect(flash[:danger]).not_to be_nil }
        it("redirects to home_path if video_id is omitted") { expect(response).to redirect_to home_path }
        it("does not add the video entry to the users's queue") { expect(user.video_queue_entries.size).to eq(0) }
      end

      context "video id does not identify a valid video" do
        before { post :create, video_queue_entry: { position: 1, video_id: 2 } }
        
        it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        it("redirects to home_path") { expect(response).to redirect_to home_path }
        it("does not add the video entry to the users's queue") { expect(user.video_queue_entries.size).to eq(0) }
      end

      context "omitted position field" do
        before do
          video2 = Fabricate(:video)
          video3 = Fabricate(:video)
          Fabricate(:video_queue_entry, user: user, video: video2, position: 1)
          Fabricate(:video_queue_entry, user: user, video: video3, position: 2)

          post :create, video_queue_entry: { video_id: Video.first.id }
        end

        it("adds the video as the last video in the queue") { expect(user.queued_videos.last).to eq(Video.first) }
        it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
        it("sets a success flash message") { expect(flash[:success]).not_to be_nil }
      end

      context "video already in user's queue" do
        before do
          Fabricate(:video_queue_entry, user: user, video: Video.first, position: 1)
          post :create, video_queue_entry: { position: 2, video_id: Video.first.id }
        end

        it("does not add the video to the queue") { expect(user.video_queue_entries.size).to eq(1) }
        it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        it("redirects to my queue path") { expect(response).to redirect_to my_queue_path }
      end
    end # logged in user
  end # POST create

  describe "POST update" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { post :update, video_queue_entry: {1 => 2, 2 => 1} } }
    end

    context "user is logged in" do
      let(:user) { Fabricate(:user) }
      before { set_current_user(user) }

      context "user_id supplied in parameters" do
        let(:user2) { Fabricate(:user) }
        before { post :update, user_id: user2.id, video_queue_entry: {1 => 2, 2 => 1} }

        context "user_id does not match current logged in user" do
          it("redirects to home path") { expect(response).to redirect_to home_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        end

        it("sets @user to the user specified by the ID") { expect(assigns(:user)).to eq(user2) }
      end # user ID in parameters

      context "user_id not provided in parameters" do
        it "sets @user to the current user" do
          post :update, video_queue_entry: {1 => 2, 2 => 1}
          expect(assigns(:user)).to eq(user)
        end
      end

      context "valid inputs" do
        context "rating change" do
          before do
            @other_user1 = Fabricate(:user)
            @other_user2 = Fabricate(:user)
            @vqe = Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: 1)
            Fabricate(:review, video: @vqe.video, user: @other_user1, rating: Review.unrated_value)
            Fabricate(:review, video: @vqe.video, user: @other_user2, rating: Review.unrated_value)
          end

          context "existing reviewed video" do

            it "redirects to my_queue" do
              Fabricate(:review, video: @vqe.video, user: user, rating: Review.unrated_value)
              post :update, video_rating: {1 => 2}             
              expect(response).to redirect_to my_queue_path
            end

            it "sets the rating of an un-rated review to a rated value" do
              Fabricate(:review, video: @vqe.video, user: user, rating: Review.unrated_value)
              post :update, video_rating: {1 => 2}
              expect(user.reviews.find_by(video_id: @vqe.video.id).rating).to eq(2)
            end

            it "does not modify reviews of other users for this video" do
              Fabricate(:review, video: @vqe.video, user: user, rating: Review.unrated_value)
              post :update, video_rating: {1 => 2}
              expect(@other_user1.reviews.first.rating).to eq(Review.unrated_value)
              expect(@other_user2.reviews.first.rating).to eq(Review.unrated_value)
            end

            it "sets the rating of a rated review to an un-rated value" do
              Fabricate(:review, video: @vqe.video, user: user, rating: 4)
              post :update, video_rating: {1 => Review.unrated_value}
              expect(user.reviews.find_by(video_id: @vqe.video.id).rating).to eq(Review.unrated_value)
            end

            it "sets the rating of a rated review to a different rated value" do
              Fabricate(:review, video: @vqe.video, user: user, rating: 4)
              post :update, video_rating: {1 => 2}
              expect(user.reviews.find_by(video_id: @vqe.video.id).rating).to eq(2)
            end
          end

          context "not reviewed video" do
            it "creates a review entry with a rated value" do
              post :update, video_rating: {1 => 2}
              expect(user.reviews.find_by(video_id: @vqe.video.id).rating).to eq(2)
            end

            it "creates a review entry with an un-rated value" do
              post :update, video_rating: {1 => Review.unrated_value}
              expect(user.reviews.find_by(video_id: @vqe.video.id).rating).to eq(Review.unrated_value)
            end

            it "adds just a single new review" do
              post :update, video_rating: {1 => Review.unrated_value}
              expect(Review.all.size).to eq(3)
            end
          end

          context "invalid video id" do
            before { post :update, video_rating: {4 => 2} }

            it "does not change any ratings" do
              expect(@other_user1.reviews.first.rating).to eq(Review.unrated_value)
              expect(@other_user2.reviews.first.rating).to eq(Review.unrated_value)
            end

            it "does not add any reviews" do
              expect(Review.all.size).to eq(2)
            end

          end
        end

        context "full reordering" do
          before do
            @vqe1 = Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: 1)
            @vqe2 = Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: 2)
            post :update, video_queue_entry: {1 => 2, 2 => 1}
          end

          it "sets position values for queue elements to those provided in inputs" do
            @vqe1.reload
            @vqe2.reload
            expect(@vqe1.position).to eq(2)
            expect(@vqe2.position).to eq(1)
          end

          it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
        end

        context "reordering to the back" do
          before { @vqe_array = [1,2,3,4].map { |i| Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: i) } }

          it "reorders positions starting with value 1 if the first queue item is placed after the end" do
            post :update, video_queue_entry: {1 => 5, 2 => 2, 3 => 3, 4 => 4 }
            @vqe_array.each { |vqe| vqe.reload }

            expect(@vqe_array[0].position).to eq(4)
            expect(@vqe_array[1].position).to eq(1)
            expect(@vqe_array[2].position).to eq(2)
            expect(@vqe_array[3].position).to eq(3)

            ## alternative and possibly better assertion we can make
            expect(user.sorted_video_queue_entries.map(&:id)).to eq([2,3,4,1])
          end

          it "reorders positions starting with value 1 if a middle queue item is placed after the end" do
            post :update, video_queue_entry: {1 => 1, 2 => 5, 3 => 3, 4 => 4 }
            @vqe_array.each { |vqe| vqe.reload }

            expect(@vqe_array[0].position).to eq(1)
            expect(@vqe_array[1].position).to eq(4)
            expect(@vqe_array[2].position).to eq(2)
            expect(@vqe_array[3].position).to eq(3)

            ## alternative and possibly better assertion we can make
            expect(user.sorted_video_queue_entries.map(&:id)).to eq([1,3,4,2])
          end
        
        end # reordering to back

      end # valid inputs

      context "invalid inputs" do
        context "non-integer position value supplied" do
          before do
            @vqe_array = [1,2,3,4].map { |i| Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: i) }
            post :update, video_queue_entry: {1 => 3, 2 => 2, 3 => 3, 4 => "foo" }
            @vqe_array.each { |vqe| vqe.reload }
          end

          it("does not alter queue positions") { @vqe_array.each_with_index { |vqe, index| expect(vqe.position).to eq(index+1) } }
          it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }          
        end


        context "position value < 1 supplied" do
          before do
            @vqe_array = [1,2,3,4].map { |i| Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: i) }
            post :update, video_queue_entry: {1 => 3, 2 => 2, 3 => 3, 4 => -5 }
            @vqe_array.each { |vqe| vqe.reload }           
          end

          it("does not alter queue positions") { @vqe_array.each_with_index { |vqe, index| expect(vqe.position).to eq(index+1) } }
          it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }          
        end

        context "duplicate position values supplied" do
          before do
            @vqe_array = [1,2,3,4].map { |i| Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: i) }
            post :update, video_queue_entry: {1 => 3, 2 => 2, 3 => 3, 4 => 1 }
            @vqe_array.each { |vqe| vqe.reload }
          end

          it("does not alter queue positions") { @vqe_array.each_with_index { |vqe, index| expect(vqe.position).to eq(index+1) } }
          it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        end

        context "missing values from order mapping" do
          before do
            @vqe_array = [1,2,3,4].map { |i| Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: i) }
            post :update, video_queue_entry: {1 => 3, 3 => 4, 4 => 5 }
            @vqe_array.each { |vqe| vqe.reload }
          end

          it("does not alter queue positions") { @vqe_array.each_with_index { |vqe, index| expect(vqe.position).to eq(index+1) } }
          it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        end

        context "extraneous ids not belonging to user's queue" do
          before do
            @vqe_array = [1,2,3,4].map { |i| Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: i) }
            user2 = Fabricate(:user)
            extra_array = [1,2,3,4].map { |i| Fabricate(:video_queue_entry, user: user2, video: Fabricate(:video), position: i) }

            post :update, video_queue_entry: {1 => 2, 2 => 3, 3 => 4, 4 => 1, 5 => 5, 6 => 6 }
            @vqe_array.each { |vqe| vqe.reload }
          end

          it("does not alter queue positions") { @vqe_array.each_with_index { |vqe, index| expect(vqe.position).to eq(index+1) } }
          it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
          it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        end
      end # invalid inputs

    end # logged in user

  end # POST update


  describe "DELETE destroy" do
    before do
      Fabricate(:user)
      Fabricate(:video)
    end

    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { delete :destroy, user_id: 1, id: 1 } }
    end # no logged in user

    context "logged in user" do
      let(:user) { Fabricate(:user) }
      before { set_current_user(user) }

      context "user_id in params does not match current logged in user" do
        let(:user2) { Fabricate(:user) }
        before do
          Fabricate(:video_queue_entry, user: user, video: Fabricate(:video), position: 1)
          delete :destroy, user_id: user2.id, id: 1
        end
          
        it("redirects to home path") { expect(response).to redirect_to home_path }
        it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        it("does not delete the video_queue_entry") { expect(VideoQueueEntry.all.size).to eq(1) }
      end

      context "the parameter id does not match a video queue entry" do
        before do
          vqe = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user)
          delete :destroy, user_id: user.id, id: 2
        end

        it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
        it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        it("does not delete any queue entries") { expect(VideoQueueEntry.all.size).to eq(1) }
      end

      context "the id identified a video queue entry for a different user than user_id parameter" do
        before do
          @user2 = Fabricate(:user)
          vqe1 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user)
          vqe2 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: @user2)
          
          delete :destroy, user_id: user.id, id: vqe2.id
        end

        it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
        it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        it "does not destroy the video queue entry" do
          expect(user.queued_videos.size).to eq(1)
          expect(@user2.queued_videos.size).to eq(1)
        end
      end

      context "the id represents a valid queue entry for the user_id" do
        before do
          @videos_array = [1,2,3,4].each.collect { |num| Fabricate(:video) }
          index = 0
          @vqe_array = @videos_array.collect { |video| Fabricate(:video_queue_entry, video: video, user: user, position: (index += 1)) }
        end

        context "general processing regardless of queued position of to be deleted video" do
          before { delete :destroy, user_id: user.id, id: @vqe_array[0].id }

          it("sets the @queue_entry") { expect(assigns(:queue_entry)).to eq(@vqe_array[0]) }
          it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
          it("sets a success flash message") { expect(flash[:success]).not_to be_nil }
        end

        context "the id represents the users's first queued video" do
          before { delete :destroy, user_id: user.id, id: @vqe_array[0].id }

          it "removes the first video from the user's queued videos" do
            expect(user.video_queue_entries.size).to eq(3)
            expect(user.video_queue_entries).to include(@vqe_array[1])
            expect(user.video_queue_entries).not_to include(@vqe_array[0])
          end

          it "adjusts the position values of the remaining queue items in the user's queue" do
            expect(user.video_queue_entries.map { |entry| entry.position }).to eq([1,2,3])
          end
        end

        context "the id represents the users's last queued video" do
          before { delete :destroy, user_id: user.id, id: @vqe_array[3].id }

          it "removes the last video from the user's queued videos" do
            expect(user.video_queue_entries.size).to eq(3)
            expect(user.video_queue_entries).to include(@vqe_array[1])
            expect(user.video_queue_entries).not_to include(@vqe_array[3])
          end

          it "adjusts the position values of the remaining queue items in the user's queue" do
            expect(user.video_queue_entries.map { |entry| entry.position }).to eq([1,2,3])
          end
        end

        context "the id represents a users's middle queued video" do
          before { delete :destroy, user_id: user.id, id: @vqe_array[2].id }

          it "removes the video from the user's queued videos" do  
            expect(user.video_queue_entries.size).to eq(3)
            expect(user.video_queue_entries).to include(@vqe_array[1])
            expect(user.video_queue_entries).not_to include(@vqe_array[2])
          end

          it "adjusts the position values of the remaining queue items in the user's queue" do
            expect(user.video_queue_entries.map { |entry| entry.position }).to eq([1,2,3])
          end
        end
      end # valid input parameters for delete operation

    end # context logged in user 
  end # DELETE destroy
end

 