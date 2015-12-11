#include <iostream>
#include <string>
#include "main.hpp"
#include "ising2d.cpp"

double RunSimulator(
  long lx,
  long ly,
  double beta,
  double h,
  long t_init,
  long t_measure,
  long seed
  ) {
  
  Ising2D sim(
      static_cast<uint32_t>(lx),
      static_cast<uint32_t>(ly),
      beta,
      h,
      static_cast<uint32_t>(seed) );
  // std::cout << sim.SerializeParameters() << std::endl;

  for( uint32_t t = 0; t < static_cast<uint32_t>(t_init); t++) {
    sim.Update();
  }

  double op_sum = 0.0;
  double op_square_sum = 0.0;
  double energy_sum = 0.0;
  for( uint32_t t = 0; t < static_cast<uint32_t>(t_measure); t++) {
    std::pair<double, double> ret = sim.UpdateAndMeasure();
    op_sum += ret.first;
    op_square_sum += ret.first * ret.first;
    energy_sum += ret.second;
    // std::cout << t << ' ' << ret.first << ' ' << ret.second << std::endl;
  }

  return op_sum / t_measure;
}

/*
int main(int argc, char const *argv[]) {

  if (argc != 8) {
    std::cerr << "Error! invalid arguments" << std::endl;
    std::cerr << "  usage: ising2d.out <lx> <ly> <beta> <H> <t_init> <t_measure> <seed>" << std::endl;
    return 1;
  }

  // Parse Input
  uint32_t lx = boost::lexical_cast<uint32_t>(argv[1]);
  uint32_t ly = boost::lexical_cast<uint32_t>(argv[2]);
  double beta = boost::lexical_cast<double>(argv[3]);
  double h = boost::lexical_cast<double>(argv[4]);
  uint32_t t_init = boost::lexical_cast<uint32_t>(argv[5]);
  uint32_t t_measure = boost::lexical_cast<uint32_t>(argv[6]);
  uint32_t seed = boost::lexical_cast<uint32_t>(argv[7]);

  Ising2D sim(lx, ly, beta, h, seed);
  // std::cout << sim.SerializeParameters() << std::endl;

  for( uint32_t t = 0; t < t_init; t++) {
    sim.Update();
  }

  double op_sum = 0.0;
  double op_square_sum = 0.0;
  double energy_sum = 0.0;
  for( uint32_t t = 0; t < t_measure; t++) {
    std::pair<double, double> ret = sim.UpdateAndMeasure();
    op_sum += ret.first;
    op_square_sum += ret.first * ret.first;
    energy_sum += ret.second;
    std::cout << t << ' ' << ret.first << ' ' << ret.second << std::endl;
  }

  // JSON dump
  std::ofstream fout("_output.json");
  fout << "{\n"
       << "  \"order_parameter\": " << op_sum / t_measure << ",\n"
       << "  \"order_parameter_fluctuation\": " << (op_square_sum / t_measure) - (op_sum/t_measure)*(op_sum/t_measure) << ",\n"
       << "  \"energy\": " << energy_sum / t_measure << "\n"
       << "}" << std::endl;

  return 0;
}
*/
