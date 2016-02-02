function Protocol = create_protocol(pos)
% pos : electrode positioning nx3

    for (i=1:size(pos,1))
        w(:,i)=1./sqrt((pos(:,1)-pos(i,1)).^2+(pos(:,2)-pos(i,2)).^2+...
            (pos(:,3)-pos(i,3)).^2);
    end
    T=tril(sparse(w));
    [ST,pred] = graphminspantree(T);
    [i,j,s]=find(ST);
    [A]=sortrows([s,i,j]);
    Protocol = A(:,2:3);
end