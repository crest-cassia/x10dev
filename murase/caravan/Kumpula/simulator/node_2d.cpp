#include <omp.h>
#include <cmath>
#include <algorithm>
#include <boost/foreach.hpp>
#include "node_2d.hpp"

double Node2D::Strength() const {
  double weight_sum = 0.0;
  for( std::vector<Edge>::const_iterator it = m_edges.begin(); it != m_edges.end(); ++it) {
    weight_sum += it->weight;
  }
  return weight_sum;
}

Edge* Node2D::EdgeSelection(Node2D* parent_node) {
  double prob_sum = 0.0;
  std::vector<double> probs( m_edges.size(), 0.0 );
  for(CEdgeIt it = m_edges.begin(); it != m_edges.end(); ++it) {
    if( it->node != parent_node ) {
      prob_sum += it->weight;
    }
    probs[ it - m_edges.begin() ] = prob_sum;
  }

  double r = prob_sum * Random::Rand01(omp_get_thread_num());
  std::vector<double>::iterator found = std::upper_bound(probs.begin(), probs.end(), r);
  // #pragma omp critical
  // {
  //   for(std::vector<double>::iterator it = probs.begin(); it != probs.end(); ++it) { std::cerr << *it << ", "; }
  //   std::cerr << std::endl;
  // }
  assert( found != probs.end() );
  return &(m_edges[ found - probs.begin() ]);
}

Edge* Node2D::FindEdge(Node2D* nj) {
  for( EdgeIt it = m_edges.begin(); it != m_edges.end(); ++it) {
    if( it->node == nj ) { return &(*it); }
  }
  return NULL;
}

void Node2D::AddEdge(Node2D* nj, double initial_weight) {
  assert( FindEdge(nj) == NULL );
  m_edges.push_back(Edge(nj, initial_weight));
}

void Node2D::EnhanceEdge(Node2D* nj, double delta) {
  Edge* edge = FindEdge(nj);
  assert(edge != NULL);
  #pragma omp atomic
  edge->weight += delta;
}

void Node2D::DeleteEdge(Node2D* nj) {
  Edge* edge = FindEdge(nj);
  assert(edge != NULL);
  *edge = m_edges.back();
  m_edges.pop_back();
  assert( FindEdge(nj) == NULL );
}

class IsLessThanThreshold {
public:
  IsLessThanThreshold(double th) : m_threshold(th) {};
  bool operator()(Edge edge) const {
    return (edge.weight < m_threshold) ? true : false;
  }
private:
  const double m_threshold;

};

void Node2D::AgingEdge(double aging_factor, double threshold) {
  for( EdgeIt it = m_edges.begin(); it != m_edges.end(); ++it) {
    it->weight *= aging_factor;
  }
  IsLessThanThreshold pred(threshold);
  m_edges.erase( std::remove_if(m_edges.begin(), m_edges.end(), pred),
                 m_edges.end());
}

double Node2D::DistanceTo( const Node2D & other ) const {
  return position.DistanceTo(other.position);
}


void Node2D::Move(double mobility, double noise) {
  Vec2D v(0.0, 0.0);

  if( m_edges.size() > 0 ) {
    Vec2D dr_sum(0.0, 0.0);
    double sum_weight = 0.0;
    for( CEdgeIt it = m_edges.begin(); it != m_edges.end(); ++it) {
      Vec2D dr = position.RelativeDir( it->node->position ) * (it->weight);
      dr_sum = dr_sum + dr;
      sum_weight += it->weight;
    }
    v = dr_sum * (mobility / sum_weight);
  }

  const int thread_num = omp_get_thread_num();
  double dx = Random::Gaussian(thread_num) * noise;
  double dy = Random::Gaussian(thread_num) * noise;
  v = v + Vec2D(dx, dy);

  position.MoveToward(v);
}

void Node2D::Flight(double beta) {
  assert( beta >= 0.0 && beta < 1.0 );
  const double x_max = 0.5;
  const double n1 = -beta + 1.0;
  const int thread_num = omp_get_thread_num();
  double r = pow( pow(x_max, n1) * Random::Rand01(thread_num) , 1.0/n1 );

  double theta = 2.0 * M_PI * Random::Rand01(thread_num);
  double dx = r * std::cos(theta);
  double dy = r * std::sin(theta);
  Vec2D v(dx, dy);


  position.MoveToward(v);
}

void Node2D::RandomizePosition() {
  const int thread_num = omp_get_thread_num();
  double x = Random::Rand01(thread_num);
  double y = Random::Rand01(thread_num);
  position.Set(x,y);
}
