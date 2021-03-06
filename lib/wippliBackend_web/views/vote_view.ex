defmodule WippliBackendWeb.VoteView do
  use WippliBackendWeb, :view
  alias WippliBackendWeb.VoteView

  def render("index.json", %{votes: votes}) do
    %{data: render_many(votes, VoteView, "vote.json")}
  end

  def render("show.json", %{vote: vote}) do
     render_one(vote, VoteView, "vote.json")
  end

  def render("vote.json", %{vote: vote}) do
    %{id: vote.id,
      rating: vote.rating}
  end
end
