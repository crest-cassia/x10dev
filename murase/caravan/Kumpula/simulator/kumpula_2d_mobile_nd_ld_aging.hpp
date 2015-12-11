#ifndef KUMPULA_2D_MOBILE_LD_HPP
#define KUMPULA_2D_MOBILE_LD_HPP

#include <omp.h>
#include <cstdlib>
#include <cassert>
#include <iostream>
#include <fstream>
#include <list>
#include <map>
#include <set>
#include <sstream>
#include <boost/cstdint.hpp>
#include <boost/random.hpp>
#include "random.hpp"
#include "node_2d.hpp"

//================================================
class Kumpula2DMobileNDLDAging {
public:
  Kumpula2DMobileNDLDAging(
    uint64_t seed, size_t net_size, double p_tri, double p_jump, double delta,
    double p_nd, double p_ld, double aging, double w_th,
    double alpha, double mobility, double noise, double p_flight, double beta
  );
  ~Kumpula2DMobileNDLDAging() {};
  void Run( uint32_t tmax);
  void PrintEdge( std::ofstream& fout);
  void PrintPositions( std::ofstream & posout);
  void ToJson( std::ostream & out ) const;
protected:
  // parameters
  const uint64_t m_seed;
  const size_t m_net_size;
  const double m_p_tri;
  const double m_p_jump;
  const double m_delta;
  const double m_p_nd;
  const double m_p_ld;
  const double m_aging;
  const double m_link_th;
  const double m_alpha;
  const double m_mobility;
  const double m_noise;
  const double m_p_flight;
  const double m_beta;

  // state variables
  std::vector<Node2D> m_nodes;
  typedef std::vector<Node2D>::iterator NodeIt;
  std::vector< std::pair<Node2D*,Node2D*> > m_enhancements;
  typedef std::vector< std::pair<Node2D*,Node2D*> >::iterator EnhanceIt;
  std::vector< std::pair<Node2D*,Node2D*> > m_attachements;
  typedef std::vector< std::pair<Node2D*,Node2D*> >::iterator AttachIt;
  std::vector<double> m_p_sums;

  void LocalAndGlobalAttachement(); // LA and GA
  void LA();
  void GA();
  void NodeMovement();
  void NodeFlight();
  void AttachPair(Node2D* i, Node2D* j, std::vector< std::pair<Node2D*,Node2D*> >& attachements);
  void EnhancePair(Node2D* i, Node2D* j, std::vector< std::pair<Node2D*,Node2D*> >& enhancements);
  void StrengthenEdges();
  void LinkDeletion();
  void LinkAging();
  void NodeDeletion();
  void DeleteNode(Node2D* ni);
  Node2D* RandomSelectExceptFor(Node2D* ni);
  Node2D* RandomSelectDependingOnDistance(Node2D* i);
  double AverageDegree();
  double AverageStrength();
  double WeightAverageLinkLength() const;
  double AverageNodeDistance() const;

  // non-copyable
  Kumpula2DMobileNDLDAging(const Kumpula2DMobileNDLDAging&);
  Kumpula2DMobileNDLDAging& operator=(const Kumpula2DMobileNDLDAging&);
};

#endif
