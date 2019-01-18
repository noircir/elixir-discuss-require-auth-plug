defmodule Discuss.TopicController do
    use Discuss.Web, :controller

    alias Discuss.Topic

    #  Guard clause 'when' to restrict to specific actions
    plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
    
    # A function plug: it will execute local function 'check_topic_owner'
    # before specified functions
    plug :check_topic_owner when action in [:update, :edit, :delete]

    def index(conn, _params) do 
        # IO.inspect(conn.assigns)
        topics = Repo.all(Topic)

        render conn, "index.html", topics: topics
    end

    def new(conn, _params) do
        struct = %Topic{}
        params = %{}
        changeset = Topic.changeset(struct, params)

        # render a form template/topic/new.html.eex
        render conn, "new.html", changeset: changeset
    end

    def create(conn, %{"topic" => topic}) do
        # IO.inspect(params)

        # conn.assigns[:user] is the same as conn.assigns.user

        # changeset = Topic.changeset(%Topic{}, topic)

        changeset = conn.assigns.user
            |> build_assoc(:topics)
            |> Topic.changeset(topic)

        case Repo.insert(changeset) do
            {:ok, _topic} -> 
                conn
                |> put_flash(:info, "Topic created")
                |> redirect(to: topic_path(conn, :index))
            {:error, changeset} -> 
                render conn, "new.html", changeset: changeset
        end
    end

    def edit(conn, %{"id" => topic_id}) do
        topic = Repo.get(Topic, topic_id)
        changeset = Topic.changeset(topic)

        render conn, "edit.html", changeset: changeset, topic: topic
    end

    def update(conn, %{"id" => topic_id, "topic" => topic}) do
        old_topic = Repo.get(Topic, topic_id)
        changeset = Topic.changeset(old_topic, topic)

        case Repo.update(changeset) do
            {:ok, _topic} -> 
                conn
                |> put_flash(:info, "Topic updated.")
                |> redirect(to: topic_path(conn, :index))
            {:error, changeset} -> 
                render conn, "edit.html", changeset: changeset, topic: old_topic
        end
    end

    def delete(conn, %{"id" => topic_id}) do 
        Repo.get!(Topic, topic_id) |> Repo.delete!
        conn 
        |> put_flash(:info, "Topic Deleted")
        |> redirect(to: topic_path(conn, :index))
    end

    def check_topic_owner(conn, _params) do
        # The 'resources' helper in TopicController (in router.ex)
        # is going to automatically pull the ':id' out of the URL
        # and attach it to the 'conn' object under the 'params' property.
        %{params: %{"id" => topic_id}} = conn
        
        # if the user_id in the database is the same as the session user_id
        if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
            conn
        else
            conn
            |> put_flash(:error, "You cannot edit that")
            |> redirect(to: topic_path(conn, :index))
            |> halt()
        end
    end
end