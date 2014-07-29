require 'sqlite3'

module ZNCLogViewer
  class Data
    def create_tables
      db.transaction do
        db.execute_batch <<-SQL
          CREATE TABLE IF NOT EXISTS `channels` (
            `id`      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            `server`  VARCHAR(255) NOT NULL,
            `channel` VARCHAR(255) NOT NULL
          );
          CREATE UNIQUE INDEX IF NOT EXISTS `index_of_server_channel` ON `channels` (`server`, `channel`);
          CREATE TABLE IF NOT EXISTS `logs` (
            `id`         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            `channel_id` INTEGER NOT NULL,
            `time`       INTEGER NOT NULL,
            `nick`       VARCHAR(255) NOT NULL,
            `message`    TEXT NOT NULL
          );
          CREATE INDEX IF NOT EXISTS `index_of_channel_id` ON `logs` (`channel_id`);
          CREATE INDEX IF NOT EXISTS `index_of_time` ON `logs` (`time`);
          CREATE INDEX IF NOT EXISTS `index_of_nick` ON `logs` (`nick`);
        SQL
      end
    end

    def insert_logs(parsed_logs, server, channel)
      channel = find_or_create_channels(server, channel)
      db.transaction do
        parsed_logs.each do |log|
          db.execute(
            'INSERT INTO `logs`(`channel_id`, `time`, `nick`, `message`) VALUES(?, ?, ?, ?)',
            channel['id'], log[:time], log[:nick], log[:message]
          )
        end
      end
    end

    def find_or_create_channels(server, channel)
      db.transaction do
        db.execute('INSERT OR IGNORE INTO `channels` (`server`, `channel`) VALUES (?, ?)', server, channel)
      end
      db.execute('SELECT * FROM `channels` WHERE `server` = ? AND `channel` = ?', server, channel).first
    end

    def db
      @db ||= SQLite3::Database.new(File.join(File.dirname(__FILE__), '../../znc-log-viewer.db'), results_as_hash: true)
    end
  end
end
