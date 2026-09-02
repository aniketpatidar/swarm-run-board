module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_account

    def connect
      set_current_account || reject_unauthorized_connection
    end

    private
      def set_current_account
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.current_account = session.account
        end
      end
  end
end
