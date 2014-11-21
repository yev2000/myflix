class LargeCoverUploader < VideoCoverUploader
  process :resize_to_fit => [665, 375]
end
