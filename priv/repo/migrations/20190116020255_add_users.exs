defmodule Discuss.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :provider, :string # provider = github, twitter, etc.
      add :token, :string

      # timestamps functon makes sure that every record has createdAt, lastModifiedAt
      timestamps()
    end

  end
end
