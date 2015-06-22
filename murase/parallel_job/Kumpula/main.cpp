#include <iostream>
#include <fstream>
#include <ctime>
#include <cstdlib>
#include <string>
#include <boost/lexical_cast.hpp>
#include <boost/format.hpp>
#include <boost/random.hpp>
#include <boost/timer.hpp>
#include "kumpula_2d_mobile_nd_ld_aging.hpp"

int RunSimulator(
    int net_size,
    double p_tri,
    double p_jump,
    double delta,
    double p_nd,
    double p_ld,
    double aging,
    double w_th,
    double alpha,
    double mobility,
    double noise,
    double p_flight,
    double beta,
    int t_max,
    int seed
  ) {
  
  std::cerr << "Lists of given parameters are as follows:" << std::endl
            << "net_size:\t" << net_size << std::endl
            << "p_tri:\t" << p_tri << std::endl
            << "p_jump:\t" << p_jump << std::endl
            << "delta:\t" << delta << std::endl
            << "p_nd:\t" << p_nd << std::endl
            << "p_ld:\t" << p_ld << std::endl
            << "aging:\t" << aging << std::endl
            << "w_th:\t" << w_th << std::endl
            << "alpha:\t" << alpha << std::endl
            << "mobility:\t" << mobility << std::endl
            << "noise:\t" << noise << std::endl
            << "p_flight:\t" << p_flight << std::endl
            << "beta:\t" << beta << std::endl
            << "t_max:\t" << t_max << std::endl
            << "seed:\t" << seed << std::endl;

  //ofstreams
  Kumpula2DMobileNDLDAging sim(seed, net_size, p_tri, p_jump, delta,
                               p_nd, p_ld, aging, w_th,
                               alpha, mobility, noise, p_flight, beta);
  boost::timer t;
  sim.Run(t_max);
  std::ofstream fout("net.edg");
  sim.PrintEdge(fout);
  fout.flush();
  std::ofstream posout("position.dat");
  sim.PrintPositions(posout);
  posout.flush();
  // std::cerr << "elapsed time : " << t.elapsed() << std::endl;

  return 0;
}

//----------------------end of the program-------------------------------
