################### backends ###################

#### CONTENT ####
backend content {
  .host = "<%= @params['content_ip'] %>";
  .port = "<%= @params['content_port'] %>";
  .probe = {
    .url = "/status.html";
    .interval = 5s;
    .timeout = 1s;
    .window = 5;
    .threshold = 3;
  }
}
# backend content_mbl {
#   .host = "<%= @params['content_backup_ip'] %>";
#   .port = "<%= @params['content_backup_port'] %>";
# }

### APPSERVERS ####
backend app1 {
  .host= "<%= @params['app1_ip'] %>";
  .port = "<%= @params['app1_port'] %>";
  .first_byte_timeout = 120s;
  .probe = { .url = "/api/ping.json"; .interval = 5s;
    .timeout = 3s; .window = 5; .threshold = 3; }
}
backend app2 {
  .host= "<%= @params['app2_ip'] %>";
  .port = "<%= @params['app2_port'] %>";
  .first_byte_timeout = 120s;
  .probe = { .url = "/api/ping.json"; .interval = 5s;
    .timeout = 3s; .window = 5; .threshold = 3; }
}
backend app3 {
  .host= "<%= @params['app3_ip'] %>";
  .port = "<%= @params['app3_port'] %>";
  .first_byte_timeout = 120s;
  .probe = { .url = "/api/ping.json"; .interval = 5s;
    .timeout = 3s; .window = 5; .threshold = 3; }
}

################## directors ###################

# These are our public app servers:
director appfarm random {
  .retries = 5;
  { .backend = app1; .weight = 5; }
  { .backend = app2; .weight = 5; }
  { .backend = app3; .weight = 5; }
}

director searchbots random {
  .retries = 5;
  { .backend = app1; .weight = 5; }
  { .backend = app2; .weight = 5; }
  { .backend = app3; .weight = 5; }
}

director apirequests random {
  .retries = 5;
  { .backend = app1; .weight = 5; }
  { .backend = app2; .weight = 5; }
  { .backend = app3; .weight = 5; }
}

sub vcl_recv {
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
# No point in compressing these
      remove req.http.Accept-Encoding;
    } else if (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    } else if (req.http.Accept-Encoding ~ "deflate") {
      set req.http.Accept-Encoding = "deflate";
    } else {
# unknown algorithm
      remove req.http.Accept-Encoding;
    }
  }
  if (req.http.user-agent ~ "Googlebot" ||
      req.http.user-agent ~ "Googlebot-Mobile" ||
      req.http.user-agent ~ "Googlebot-Image" ||
      req.http.user-agent ~ "rogerbot" ||
      req.http.user-agent ~ "msnbot-UDiscovery" ||
      req.http.user-agent ~ "msnbot-Udiscovery" ||
      req.http.user-agent ~ "Gigabot" ||
      req.http.user-agent ~ "msnbot-media" ||
      req.http.user-agent ~ "bingbot" ||
      req.http.user-agent ~ "YandexBot" ||
      req.http.user-agent ~ "NAVER Blog Rssbot" ||
      req.http.user-agent ~ "ScoutJet" ||
      req.http.user-agent ~ "Exabot-Thumbnails" ||
      req.http.user-agent ~ "Exabot" ||
      req.http.user-agent ~ "FriendFeedBot" ||
      req.http.user-agent ~ "Ezooms" ||
      req.http.user-agent ~ "Netluchs" ||
      req.http.user-agent ~ "msnbot" ||
      req.http.user-agent ~ "YodaoBot" ||
      req.http.user-agent ~ "Yahoo! Slurp" ||
      req.http.user-agent ~ "Diffbot" ||
      req.http.user-agent ~ "gsa-crawler" ||
      req.http.user-agent ~ "psbot" ||
      req.http.user-agent ~ "Yeti" ||
      req.http.user-agent ~ "microbot" ||
      req.http.user-agent ~ "magpie-crawler" ||
      req.http.user-agent ~ "ia_archiver(OS-Wayback)" ||
      req.http.user-agent ~ "ia_archiver" ||
      req.http.user-agent ~ "AdsBot-Google" ||
      req.http.user-agent ~ "EdisterBot" ||
      req.http.user-agent ~ "MLBot" ||
      req.http.user-agent ~ "PiplBot" ||
      req.http.user-agent ~ "MS Search 5.0 Robot" ||
      req.http.user-agent ~ "HuaweiSymantecSpider" ||
      req.http.user-agent ~ "ShopWiki" ||
      req.http.user-agent ~ "itim" ||
      req.http.user-agent ~ "suggybot" ||
      req.http.user-agent ~ "AhrefsBot" ||
      req.http.user-agent ~ "yacybot" ||
      req.http.user-agent ~ "Daumoa" ||
      req.http.user-agent ~ "YodaoBot-Image" ||
      req.http.user-agent ~ "YodaoBot" ||
      req.http.user-agent ~ "Speedy Spider" ||
      req.http.user-agent ~ "discobot" ||
      req.http.user-agent ~ "MJ12bot" ||
      req.http.user-agent ~ "Baiduspider" ||
      req.http.user-agent ~ "Doubanbot" ||
      req.http.user-agent ~ "Setooz" ||
      req.http.user-agent ~ "Spinn3r" ||
      req.http.user-agent ~ "WebTrends" ||
      req.http.user-agent ~ "Slurp" ||
      req.http.user-agent ~ "YandexBot" ||
      req.http.user-agent ~ "msnbot" ||
      req.http.user-agent ~ "Smithsonian-Public-GSA" ||
      req.http.user-agent ~ "PaperLiBot") {
        set req.backend = searchbots;
  } elseif (req.url ~ "/testaction" ) {
    return(error);
  } elseif (req.url ~ "^/api" ) {
    set req.backend = apirequests;
  } elseif (req.url ~ "^/content/20") {
    unset req.http.Cookie;
    unset req.http.Authorization;
    unset req.http.cache-control;
    unset req.http.pragma;
    unset req.http.expires;
    unset req.http.etag;
    unset req.http.X-Forwarded-For;
    set req.backend = content;
    set req.http.host = "10.0.0.31";
  } elseif (req.http.host ~ "10.0.0.31$") {
    unset req.http.Cookie;
    unset req.http.Authorization;
    set req.backend = content_mbl;
  } else {
    set req.backend = appfarm;
  }
}

# ################### vcl_recv ###################
# sub vcl_recv {
# # Before anything else we need to fix gzip compression
#   if (req.http.Accept-Encoding) {
#     if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
# # No point in compressing these
#       remove req.http.Accept-Encoding;
#     } else if (req.http.Accept-Encoding ~ "gzip") {
#       set req.http.Accept-Encoding = "gzip";
#     } else if (req.http.Accept-Encoding ~ "deflate") {
#       set req.http.Accept-Encoding = "deflate";
#     } else {
# # unknown algorithm
#       remove req.http.Accept-Encoding;
#     }
#   }
# # Temporary redirect to mbl while we fix edge
# # comment out this after it is done
# # } elseif (req.url ~ "^/content/20") {
# #   unset req.http.Cookie;
# #   unset req.http.Authorization;
# #   unset req.http.cache-control;
# #   unset req.http.pragma;
# #   unset req.http.expires;
# #   unset req.http.etag;
# #   unset req.http.X-Forwarded-For;
# #   set req.backend = content_mbl;
# #   set req.http.host = "content_mbl.eol.org";
# } elseif (req.http.host ~ "content_mbl.eol.org$") {
#   unset req.http.Cookie;
#   unset req.http.Authorization;
#   set req.backend = content_mbl;
# } else {
#   set req.backend = appfarm;
# }
#
# #forbidden clients
# if (client.ip ~ forbidden) {
#   error 403 "Forbidden";
# }
