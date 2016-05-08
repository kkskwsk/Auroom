function v = draw_vector(point_of_origin, direction, t_param)
  vector = point_of_origin + t_param*direction;
  t = 0:0.1:100;
  plot3(vector, t);
  