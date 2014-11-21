class SmallCoverUploader < VideoCoverUploader
  process :resize_to_fit => [166, 236]
end