function L = gen_Laplacian_matrix(XYZ,neighbour_dist)     
%

  %N_max = 6; THIS IS CHEESY GUSTAVO CODE
    
  % n: number of elements
  n  = size(XYZ,1);
  
  % initialise L
  L = sparse(n,n);
  
  lb = neighbour_dist*.99;
  ub = neighbour_dist*1.01;
  
  tic
  % iterate over elements
  for chosen_el = 1:n
      % find neighbouring elements 
      dist = sqrt(sum((XYZ-repmat(XYZ(chosen_el,:),n,1)).^2,2));      
      chosen = find(dist>lb & dist<ub);      
      %L(chosen_el,chosen_el) = -N_max; THIS IS CHEESY GUSTAVO CODE
      L(chosen_el,chosen_el) = -length(chosen);
      L(chosen_el,chosen) = 1;
      if mod(chosen_el,1000)==0
          disp(num2str([chosen_el,toc/60]))
      end
  end
  