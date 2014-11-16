LineupApi::Application.routes.draw do
  post 'lineup' => 'lineup#optimal'
  get 'players' => 'lineup#players'
end
