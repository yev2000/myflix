def visit_leader_who_reviewed_movie(movie, leader)
  click_video_image(movie)

  leader_review_link = review_from_user_link(leader)
  expect(leader_review_link).not_to be nil

  leader_review_link.click
end

def follow_leader_who_reviewed_movie(movie, leader)
  visit_leader_who_reviewed_movie(movie, leader)

  # this takes us to leaders's page
  # we should see a follow link there
  expect(page).to have_selector("input[value='Follow']")

  follow_link = find_follow_link_on_user_page
  expect(follow_link).not_to be_nil

  follow_link.click
end

def review_from_user_link(user)
  article_items = all("article[class='review']")

  article_items.each do |article|
    link_element = article.find("a")
    if (link_element.text == user.fullname)
      return link_element
    end
  end

  return nil
end

def find_follow_link_on_user_page
  find("input[value='Follow']")
end

def find_leader_row_or_link_in_people_table(leader, type)
  row_items = all("tr")
  row_items.each do |row_item|
    row_item.all("a[href]").each do |link_element|
      if (link_element.text == leader.fullname)
        if (type == :row)
          return row_item
        else
          return link_element
        end
      end
    end
  end

  return nil
end  

def find_leader_row_in_people_table(leader)
  find_leader_row_or_link_in_people_table(leader, :row)
end

def find_leader_link_in_people_table(leader)
  find_leader_row_or_link_in_people_table(leader, :link)
end

def find_unfollow_link_in_leader_row(leader_row)
  leader_row.find("a[rel='nofollow']")
end

