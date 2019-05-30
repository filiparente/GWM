function A = create_matrix(rows, cols, val)
   %Create a new rows x cols matrix, whose entries are equal to the specified value
   A = [];
   if cols ~= 1 || cols ~= 0
      for i=1:rows
         A = [A; []];
      end
      for i=1:rows
         for j=1:cols
            A(i) = [A(i), val];
         end
      end
   else
      for i=1:rows
         A = [A;val];
      end
   end
end
