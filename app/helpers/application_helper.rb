module ApplicationHelper
  
  # taken from mobile_fu
  MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                       'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                       'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                       'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                       'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                       'mobile'
                       
  MOBILE_USER_AGENT_REGEX = /#{MOBILE_USER_AGENTS}/i
  
  def is_mobile_device?
    request.user_agent.to_s.match(MOBILE_USER_AGENT_REGEX).present?
  end

  def active_if(condition)
    'active' if condition
  end

  def member_profile_page?(member)
    member.present? && current_page?(member_profile_path(member))
  end
  
end
