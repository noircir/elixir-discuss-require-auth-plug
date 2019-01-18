defmodule Discuss.Plugs.SetUser do
    import Plug.Conn            # assign

    alias Discuss.Repo
    alias Discuss.User

    def init(_params) do
    end

    #--------------------------------------------------------------------------
    # The 'signin' process in AuthController created a session with a user_id. 
    # The purpose of this plug is to associate the session's user_id 
    # with further user information from db (if the user exists).  
    #--------------------------------------------------------------------------

    # 'params' is whatever is returned from the 'init' function.
    def call(conn, _params) do
        user_id = get_session(conn, :user_id) 

        cond do
            user = user_id && Repo.get(User, user_id) ->
                assign(conn, :user, user)
            true -> 
                assign(conn, :user, nil)
        end
    end
end
