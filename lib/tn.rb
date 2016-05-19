module TN
  def self.execute_sql(sql, *placeholders)
    ActiveRecord::Base.connection.select_value(ActiveRecord::Base.send(:sanitize_sql_array, [sql, *placeholders]))
  end
end
