xml.Worksheet 'ss:Name' => I18n.t(:tab_time_tracking) do
  xml.Table do
    unless @time_records.empty?
      # Header.
      xml.Row do
        heads = [I18n.t('date_started'),
                 I18n.t('user'),
                 I18n.t('account'),
                 I18n.t('project'),
                 I18n.t('target'),
                 I18n.t('description'),
                 I18n.t('time_spent')]

        heads.each do |head|
          xml.Cell do
            xml.Data head,
                     'ss:Type' => 'String'
          end
        end
      end

      @time_records.each do |time_record|
        xml.Row do
          data = [
              time_record.date_started.to_date,
              time_record.user.try(:full_name),
              time_record.account.try(:name),
              time_record.project.try(:name),
              time_record.target,
              time_record.description,
              time_record.time_spent
          ]

          data.each do |value|
            xml.Cell do
              xml.Data value,
                       'ss:Type' => "#{value.respond_to?(:abs) ? 'Number' : 'String'}"
            end
          end
        end
      end
    end
  end
end
