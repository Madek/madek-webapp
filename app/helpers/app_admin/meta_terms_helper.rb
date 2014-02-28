module AppAdmin::MetaTermsHelper
  def used_as(meta_term)
    html = ""
    MetaTerm::USAGE.each do |type|
      html << content_tag(:p, type.to_s.humanize) if meta_term.used_as?(type)
    end
    html.html_safe
  end
end
