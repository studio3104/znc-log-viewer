$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'sinatra'
require 'znc-log-viewer/server'

run ZNCLogViewer::Server
