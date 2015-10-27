module ApplicationHelper

def title(title = nil)
  if title.present?
    content_for :title, title
  else
    content_for?(:title) ? "ARM Calculator" + ' | ' + content_for(:title) : "ARM Calculator"
  end
end

def description(description = nil)
  if description.present?
    content_for :description, description
  else
    content_for?(:description) ? content_for(:description) : "ARM Calculator"
  end
end

end
