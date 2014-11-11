def click_add_to_queue
  click_button "+ My Queue"
end

def add_video_to_queue(video)
  click_myflix_home
  click_video_image(video)
  click_add_to_queue
end


def click_update_queue
  click_button "Update Instant Queue"
end

def set_queue_video_order_low_level(new_order)
  # this is no longer used, once we added the
  # data-video-id-<#> to the input field in
  # the queue template
  all("tr").each_with_index do |row_node, index|
    if (index > 0)
      moved_video = Video.find(index)
      row_node.all("input")[0].set (new_order.index(moved_video) + 1).to_s
    end
  end
end

def check_queue_rows_low_level
  # this is no longer used, but here for reference in terms
  # of a low-level implementation that is brittle and does not use
  # xpath effectively
  all("tr").each_with_index do |row_node, index|
    if (index > 0)
      expect(row_node.all("input")[0].value).to eq(index.to_s)
      expect(row_node.all("a")[0].text).to eq(Video.find(index).title)
    end
  end
end

def set_queue_video_order(new_order)
  new_order.each_with_index do |video, index|
    find("input[data-video-id='#{video.id}']").set((index + 1).to_s)
  end
end
