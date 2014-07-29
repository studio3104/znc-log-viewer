require 'zlib'

module ZNCLogViewer
  class LogFileParser
    def self.parse(path)
      server, channel, day = parse_log_filename(path)
      text = if path.end_with?('.gz')
               read_gzip_log(path)
             else
               read_raw_log(path)
             end

      logs = parse_log_body(text, day)
      { server: server, channel: channel, logs: logs }
    end

    private

    def self.parse_log_body(text, day)
      logs = []

      text.each_line do |line|
        unless m = line.match(/^\[(?<time>[^\]]+)\] \<(?<nick>[^\>]+)\> (?<message>.+)/)
          if m = line.match(/^\[(?<time>[^\]]+)\] \-(?<nick>[^\-]+)\- (?<message>.+)/)
            notice = true
          end
        end

        if m
          message = notice ? 'NOTICE: ' + m[:message] : m[:message]
          logs << {
            time: Time.parse(day + ' ' + m[:time]).to_i,
            nick: m[:nick], message: message.chomp
          }
        end
      end

      logs
    end

    def self.parse_log_filename(path)
      # ログファイル名のパターン
      # 通常: servername_#channel_20140520.log
      # PrivMsg: servername_nickname_20140520.log
      filename = File.basename(path).sub(/\.log(\.gz)?$/, '')

      # server名に '_' を含んでるとちゃんと動きません
      property = filename.split('_')
      server = property.shift
      day = property.pop
      channel = property.join('_')

      [ server, channel, day ]
    end

    def self.read_raw_log(path)
      text = ''
      File.open(path) do |raw|
        text += raw.read
      end
      text
    end

    def self.read_gzip_log(path)
      text = ''
      Zlib::GzipReader.open(path) do |gz|
        text += gz.read
      end
      text
    end
  end
end
