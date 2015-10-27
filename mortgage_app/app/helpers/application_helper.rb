module ApplicationHelper

def title(title = nil)
  if title.present?
    content_for :title, title
  else
    content_for?(:title) ? "ARM Calculator" + ' | ' + content_for(:title) : "ARM Calculator"
  end
end

end
