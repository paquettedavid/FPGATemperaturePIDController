disp(Plant2);
disp(C);
f = feedback(C*Plant2,1);
step(f)