function tests = axesPropertiesTest
tests = functiontests(localfunctions);
end


function testVerify(testCase)
% addpath('../src/matlab');
% load('../resources/mesh/Ex_Cyl_Small.mat'); %load the Mesh and the Jacobian (from fwd solver), and the boundary votlages DV
% %[h]=DisplayBoundaries(Mesh);
% %create hex mesh and hex jacobian - 10mm elements
% [Mesh_hex,J_hex]=convert_fine2coarse(Mesh.Tetra,Mesh.Nodes,J,0.2);
% n_J = size(J_hex,1);% J is the Jacobian matrix
% nLambda=3000;
% %SVD
% [U,S,V] = svd(J_hex,'econ');% Singular value decomposition
% disp(sprintf('SVD done: %.2f min.',toc/60))
% %pick lambda searchspace
% lambda = logspace(-20,-2,nLambda);
% %Do inversion
% [X,cv_error] = tikhonov_CV(J_hex,DV,lambda,n_J,U,S,V,0);% DV is the measurement.

verifyEqual(testCase, 1,1)
verifyEqual(testCase, 1,1)
verifyEqual(testCase, 1,1)
end

function testA(testCase)
verifyEqual(testCase, 1,3)
verifyEqual(testCase, 1,1)
verifyEqual(testCase, 'x',2,'sdf')
end



% function f = createFigure
% f = figure;
% ax = axes('Parent', f);
% cylinder(ax,10)
% h = findobj(ax,'Type','surface');
% h.FaceColor = [1 0 0];
% end
% 
% 
% function setupOnce(testCase)
% % create and change to temporary folder
% testCase.TestData.origPath = pwd;
% testCase.TestData.tmpFolder = ['tmpFolder' datestr(now,30)];
% mkdir(testCase.TestData.tmpFolder)
% cd(testCase.TestData.tmpFolder)
% 
% % create and save a figure
% testCase.TestData.figName = 'tmpFig.fig';
% aFig = createFigure;
% saveas(aFig,testCase.TestData.figName,'fig')
% close(aFig)
% end
% 
% function teardownOnce(testCase)
% delete(testCase.TestData.figName)
% cd(testCase.TestData.origPath)
% rmdir(testCase.TestData.tmpFolder)
% end
% 
% function setup(testCase)
% testCase.TestData.Figure = openfig(testCase.TestData.figName);
% testCase.TestData.Axes = findobj(testCase.TestData.Figure,...
%     'Type','Axes');
% end
% 
% function teardown(testCase)
% close(testCase.TestData.Figure)
% end
% 
% 
% 
% function testDefaultXLim(testCase)
% xlim = testCase.TestData.Axes.XLim;
% verifyLessThanOrEqual(testCase, xlim(1), -10,...
%     'Minimum x-limit was not small enough')
% verifyGreaterThanOrEqual(testCase, xlim(2), 10,...
%     'Maximum x-limit was not big enough')
% end
% 
% 
% function surfaceColorTest(testCase)
% h = findobj(testCase.TestData.Axes,'Type','surface');
% co = h.FaceColor;
% verifyEqual(testCase, co, [1 0 0],'FaceColor is incorrect')
% end
% 


