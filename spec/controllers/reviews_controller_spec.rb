require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe ReviewsController do 
  describe "POST create" do

    context "no logged in user" do
      it "redirects to the sign_in page" do
        post :create, {video_id: 1, review: Fabricate.attributes_for(:review) }
        expect(response).to redirect_to sign_in_path
      end
    end
  
    context "logged in user" do
      before { set_current_user }

      context "missing video" do
        before { post :create, {video_id: 1, review: Fabricate.attributes_for(:review) } }

        it ("flashes an error message if video ID does not refer to an extant video") { expect(flash[:danger]).not_to eq(nil) }
        it ("redirects to videos URL if video ID does not refer to an extant video") { expect(response).to redirect_to videos_path }
        it ("does not create a review") { expect(Review.all.size).to eq(0) }

      end

      context "video exists" do
        before { Fabricate(:video) }

        it "sets @video" do
          post :create, {video_id: Video.first.id, review: Fabricate.attributes_for(:review) }
          expect(assigns(:video)).to eq(Video.first)
        end

        context "missing fields" do

          it "sets review instance variable with an error message if title is missing" do
            post :create, {video_id: Video.first.id, review: { rating: 4, body: "test body" }}
            expect(assigns(:review).errors.messages).not_to be_nil
          end

          it "sets @review with an error message if body is missing" do
            post :create, {video_id: Video.first.id, review: { rating: 4, title: "test title" }}
            expect(assigns(:review).errors.messages).not_to be_nil
          end

          it "sets @review with an error message if rating is missing" do
            post :create, {video_id: Video.first.id, review: { body: "test body", title: "test title" }}
            expect(assigns(:review).errors.messages).not_to be_nil
          end

          it "redirects to video show page if title is missing" do
            post :create, {video_id: Video.first.id, review: { rating: 4, body: "test body" }}
            expect(response).to render_template :show
          end

          it "redirects to video show page if body is missing" do
            post :create, {video_id: Video.first.id, review: { rating: 4, title: "test title" }}
            expect(response).to render_template :show
          end

          it "redirects to video show page if rating is missing" do
            post :create, {video_id: Video.first.id, review: { body: "test body", title: "test title" }}
            expect(response).to render_template :show
          end
        end # context of missing fields

        context "video exists and required review fields filled in" do
          context "video already reviewed by logged in user" do
            before do
              prior_review = Fabricate(:review, video: Video.first, user: spec_get_current_user)
              post :create, {video_id: Video.first.id, review: Fabricate.attributes_for(:review) }
            end

            # only one review in the system - the one that was the prior_review
            # so no new ones added
            it("does not create the review") { expect(Review.all.size).to eq(1) }

            it("sets @review with an error message") { expect(assigns(:review).errors.messages).not_to eq(nil) }
            it("re-renders show video page") { expect(response).to render_template :show }
          end

          context "video not yet reviewed by logged in user" do
            before { post :create, video_id: Video.first.id, review: Fabricate.attributes_for(:review) }

            it("flashes success message for a valid review") { expect(flash[:success]).not_to be_nil }
            it("creates the review") { expect(Review.all.size).to eq(1) }
            it("associates the review with the reviewed video") { expect(Video.first.reviews.size).to eq(1) }
            it("associates the review with the current logged in user") { expect(Review.first.user).to eq(spec_get_current_user) }
            it("redirects to show video page") { expect(response).to redirect_to video_path(Video.first) }
          end

        end # video exists and required fields all filled in
      end # video exists context
    end
  end
end
