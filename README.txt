DYNAMO - Quantum Dynamic Optimization Package v1.0

(c) Shai Machnes 2010, 
Institute of Theoretical Physics, 
Ulm University, 
Germany
email: shai.machnes at uni-ulm.de

Released under the terms of the Lesser GNU Public License and Creative-Commons Attribution Share-Alike (see "license.txt" for details).

If you use DYNAMO in your research, please add an attribution in the form of the following reference: 
S. Machnes et-al, arXiv 1011.4874 

For the latest version of this software, guides and information, visit http://www.qlib.info

The best way to understand DYNAMO is review the demos.            

Before running the demos, please make sure the 'Dynamo' directory is in MATLAB's search path by entering the following command

    addpath('Dynamo'); % Replace 'Dynamo' with the name of the directory where Dynamo files (such as 'BFGS_search_function.m') reside.

What are the demos ?

    run_me_dynamo_demo_00           Using DYNAMO to solve a simple gate-synthesis problem. 
                                    If your interests are focused on finding optimal control sequences for your specific system - this file is all you need to understand.
    run_me_dynamo_demo_01           This demo will optimize a simple two-qubit QFT gate generation problem using a wide variety of algorithms
                                    If you are interested in OC algorithm research, this is the place for you

To understand a bit more about the inner-workings of DYNAMO, please read INTRO_TO_DYNAMO.txt


