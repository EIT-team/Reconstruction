function Protocol = create_protocol(pos)
% pos : electrode positioning nx3


%    Create weights for spanning tree based on vector distance between
%    electrodes
    for i=1:size(pos,1)
        w(:,i)=1./sqrt((pos(:,1)-pos(i,1)).^2+(pos(:,2)-pos(i,2)).^2+...
            (pos(:,3)-pos(i,3)).^2);
    end
    
    %find graph which connects the electrodes with biggest length
    T=tril(sparse(w));
    [ST,pred] = graphminspantree(T);
    %convert into array
    [i,j,s]=find(ST);
    %put in order 
    [A]=sortrows([s,i,j]);
    %take only the node numbers
    Protocol = A(:,2:3);
end