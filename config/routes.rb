LineupApi::Application.routes.draw do
  get 'lineup' => 'lineup#optimal'
  get 'players' => 'lineup#players'
end
