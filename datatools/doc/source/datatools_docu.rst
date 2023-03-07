

Welcome to datatools's documentation!
=====================================

.. toctree::
   :maxdepth: 3

A short introduction
----------------------

The idea of the underlying dataformat is to be as flexible as possible
in regards to the type of data that can be stored while remaining
human readable.

This dataformat is constructed to save data returned by a model/subject for different stimulus/tests.
This two dimensions are essential in each kind of experiment: Each data point (result / recording / answer) depends on the stimulus :math:`x_j`  and on the subject/model :math:`a_i`:

:math:`y_{i,j} = f ( a_{i},x_{j})`,





An underlying assumption is that the parameter space is split into two
categories:
  - The stimulus parameters :math:`s` called *spar*
  - The model (or subject) parameters :math:`a` called *mpar*

Both *spar* and *mpar* are arrays of numeric values where each column
represents one parameter. As a result, each row of *mpar* is a set of
parameters defining a specific model. Each row of *spar* defines a
stimulus. The *data* is thus the result of presenting each of the
stimuli defined by *spar* to each of the models defined by *mpar*:

:math:`y_{i,j} = f ( a_{i,m},x(s_{j,k}) )`,

with		 	 	

=====================================  ========================================================  ==========================
symbol                                 description                                               variable name (code)
=====================================  ========================================================  ==========================
:math:`y`                              result for a single subject for a single condition   
:math:`\mathbf Y = y_{i,j}`            results                                                   results.data 

:math:`x(\overline{s})`                stimulus                                                  stim 
:math:`i \in [1,2,...,I]`              index for model parameter combinations / instances        i\_minst 
:math:`I`                              number of model parameter  instances / subjects           n\_minst 
:math:`j \in [1,2,...,J]`              index for stimulus parameter instances                    i\_sinst 
:math:`J`                              number of stimulus parameter instances                    n\_sinst 
dim :math:`y`                          dimension of :math:`y`                                    n\_dim 
:math:`f`                              function / model                                        
:math:`a_m = [a_{1},a_{2},...,a_{M}]`  model parameters                                          mpar 
:math:`M`                              number of model parameters                                n\_mpar 
:math:`m \in [1,2,...,M]`              index for model parameters                                i\_mpar 
:math:`s_k = [s_{1},s_{2},...,s_{K}]`  stimulus parameters                                       spar 
:math:`K`                              number of stimulus parameters                             n\_spar 
:math:`k \in [1,2,...,S]`              index for stimulus parameters                             i\_spar .
=====================================  ========================================================  ==========================


In Matlab, the datatype is implemented as a struct with the *mpar* and
*spar* stored in the **mpar_table** and **spar_table** fields. Results
are stored in the **data** field. To store information about each of
the parameters as well as data the three additional fields
**mpar_info**, **spar_info** and **data_info** are used

Overview over the fields of the data struct:

 - data (array)
 - mpar_table (array)
 - spar_table (array)
 - data_info (struct)
 - mpar_info (array of struct)
 - spar_info (array of struct)

the two fields **mpar_info** and **spar_info** are arrays of structs
where the dimension of the array is the same as the number of
parameters. If **mpar_table** has two columns and thus two
parameters - **mpar_info** will also contain two structs, each
describing one of the parameters.

A simple example could be:

  * mpar_info[1]
      - 'name' : 'freq'
      - 'unit' : 'Hz'
      - 'description' : 'The stimulus frequency'
      - ...
  * mpar_info[2]
      - 'name' : 'level'
      - 'unit' : 'dBSPL'
      - ...

The only mandatory field per **mpar_info** entry is 'name' all other
fields are optional but some, such as 'unit' are encouraged.

**data_info** provides similar information but on the result data. The
 only mandatory field here is 'ndim' which is the number of dimensions
 for the results. In many cases other fields e.g. sampling frequency (fs) are mandatory as well.  But again a description and units are encouraged

data_info
    - 'ndim' : 2

would thus define that the results are stored within two
dimensions. All other dimensions of data are defined by the number of
rows given in **mpar_table** and **spar_table**.

Example:

**mpar_table** has the dimensions (2, 3) which means that the model is
defined by three parameters, two sets of parameters are
saved. **spar_table** has the dimensions (6, 4) - four parameters
define the stimulus, 6 sets of parameters are contained in the table.
if 'ndim' in **data_info** is 2, then the result array **data** could
have the dimensions (9, 13, 2, 6).
  - Each result has the dimension (9, 13)
  - 2 sets of *mpar*
  - 6 sets of *spar*

the results for the second set of model paramters gained with the
first stimulus are thus accessed as mystruct.data[:, :, 2, 1]


Function Documentation
----------------------
Functions that build-up or edit the dataformat
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. automodule:: datatools
.. autofunction:: add_mpar
.. autofunction:: add_spar
.. autofunction:: add_mpar_inst
.. autofunction:: add_spar_inst

Functions that use the dataformat
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. autofunction:: mpar_by_name
.. autofunction:: spar_by_name
.. autofunction:: get_mpar_index
.. autofunction:: get_spar_index
.. autofunction:: run_exp 
.. autofunction:: mpar_mean_by_name
.. autofunction:: spar_mean_by_name
