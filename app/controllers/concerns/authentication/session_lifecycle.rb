# frozen_string_literal: true

module Authentication
  module SessionLifecycle
    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def start_new_session_for(account)
      session = create_session_for(account)
      Current.session = session
      remember(session)
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end

    private
      def find_session_by_cookie
        session_id = cookies.signed[:session_id]
        Session.find_by(id: session_id) if session_id
      end

      def create_session_for(account)
        account.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      end

      def remember(session)
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
  end
end
