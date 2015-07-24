svd=matlab.unittest.TestSuite.fromFile('unitTest_svd.m');
tik=matlab.unittest.TestSuite.fromFile('unitTest_tikhonov.m');

utest_suit=[svd,tik];
utest_result=utest_suit.run;