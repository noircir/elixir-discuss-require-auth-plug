defmodule Discuss.AuthController do
    use Discuss.Web, :controller
    plug Ueberauth

    alias Discuss.User

    # ==============================================================================
    # There is no explicit :request route (/auth/github); it's handled by Ueberauth.
    # The /auth/callback is what Ueberauth needs after authentication.
    # ==============================================================================

    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
        # IO.puts "+++++++++++++++"
        # IO.inspect(conn.assigns.ueberauth_auth)
        # IO.inspect(auth)
        # IO.inspect(params)
        # IO.puts "+++++++++++++++"
        # IO.inspect(params)
        # IO.puts "+++++++++++++++"

        # Take returned information and save in the db
        user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
        changeset = User.changeset(%User{}, user_params)

        # After authenticating with Github, configure a session
        signin(conn, changeset)
    end

    def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: topic_path(conn, :index))
  end

  #  If the user is not found in the db, add a record. 
  #  Repo.insert wiil return {:ok, user} in the case of success.
  #  Re-use the user_id in the session if the user exists.

  #  Message "Welcome back!" here is shown for a new user as well, though it shouldn't.
  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end
end
