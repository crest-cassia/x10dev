#include <cmath>
#include "kumpula_2d_mobile_nd_ld_aging.hpp"

Kumpula2DMobileNDLDAging::Kumpula2DMobileNDLDAging(
  uint64_t seed, size_t net_size, double p_tri, double p_jump, double delta,
  double p_nd, double p_ld, double aging, double w_th,
  double alpha, double mobility, double noise, double p_flight, double beta)
: m_seed(seed), m_net_size(net_size), m_p_tri(p_tri), m_p_jump(p_jump), m_delta(delta),
  m_p_nd(p_nd), m_p_ld(p_ld), m_aging(aging), m_link_th(w_th),
  m_alpha(alpha), m_mobility(mobility), m_noise(noise),
  m_p_flight(p_flight), m_beta(beta)
{
  #pragma omp parallel
  {
    int num_threads = omp_get_num_threads();
    #pragma omp master
    {
      std::cerr << "num_threads: " << num_threads << std::endl;
      Random::Init(seed, num_threads);
      for( size_t i = 0; i < m_net_size; i++) {
        Node2D node(i);
        m_nodes.push_back( node );
      }
    }
  }
}

void Kumpula2DMobileNDLDAging::Run( uint32_t t_max) {
  std::ofstream fout("timeseries.dat");

  #pragma omp parallel
  {
    for( uint32_t t=0; t < t_max; ++t) {
      LocalAndGlobalAttachement();

      #pragma omp master
      {
        if( m_p_nd > 0.0 ) {
          NodeDeletion();
        }
        if( m_p_ld > 0.0 ) {
          LinkDeletion();
        }
        if( m_aging < 1.0 ) {
          LinkAging();
        }
        if( t % 128 == 127 ) {
          std::cerr << "t: " << t << std::endl;
          fout << t << ' ' << AverageDegree()
               << ' ' << AverageStrength()
               << ' ' << WeightAverageLinkLength()
               << ' ' << AverageNodeDistance()
               << std::endl;
        }
      }
      #pragma omp barrier

      NodeMovement();
      NodeFlight();
    }
  }
}

void Kumpula2DMobileNDLDAging::PrintEdge( std::ofstream & fout) {
  for( size_t i=0; i < m_nodes.size(); i++) {
    const std::vector<Edge> edges = m_nodes[i].GetEdges();
    for( std::vector<Edge>::const_iterator it = edges.begin(); it != edges.end(); ++it) {
      size_t j = it->node->GetId();
      if( i < j ) { fout << i << ' ' << j << ' ' << it->weight << std::endl; }
    }
  }
}

void Kumpula2DMobileNDLDAging::PrintPositions( std::ofstream & posout) {
  for( size_t i=0; i < m_nodes.size(); i++) {
    const Vec2D& pos = m_nodes[i].GetPosition();
    posout << m_nodes[i].GetId() << ' ' << pos.GetX() << ' ' << pos.GetY() << std::endl;
  }
}

void Kumpula2DMobileNDLDAging::ToJson( std::ostream& out ) const {
  out << "{ \"num_nodes\": " << m_nodes.size() << ", \"nodes\": [\n";

  for( size_t i=0; i < m_nodes.size(); i++) {
    const Vec2D& pos = m_nodes[i].GetPosition();
    out << "[" << pos.GetX() << "," << pos.GetY() << "]";
    if( i != m_nodes.size() - 1 ) { out << ",\n"; }
    else { out << "],\n"; }
  }

  out << "\"links\": [\n";
  std::string token = "";
  for( size_t i=0; i < m_nodes.size(); i++) {
    const std::vector<Edge> edges = m_nodes[i].GetEdges();
    for( std::vector<Edge>::const_iterator it = edges.begin(); it != edges.end(); ++it) {
      size_t j = it->node->GetId();
      if( i < j ) {
        out << token << "[" << i << "," << j << "," << it->weight << "]";
        token = ",\n";
      }
    }
  }
  out << "]}";
}

double Kumpula2DMobileNDLDAging::AverageDegree() {
  size_t total = 0;
  for( NodeIt it = m_nodes.begin(); it != m_nodes.end(); ++it) {
    total += it->Degree();
  }
  return static_cast<double>(total) / m_nodes.size();
}

double Kumpula2DMobileNDLDAging::AverageStrength() {
  double total = 0.0;
  for( NodeIt it = m_nodes.begin(); it != m_nodes.end(); ++it) {
    total += it->Strength();
  }
  return total / m_nodes.size();
}

double Kumpula2DMobileNDLDAging::WeightAverageLinkLength() const {
  double total = 0.0;
  double total_weight = 0.0;
  for( size_t i=0; i < m_nodes.size(); i++) {
    const std::vector<Edge> edges = m_nodes[i].GetEdges();
    for( std::vector<Edge>::const_iterator it = edges.begin(); it != edges.end(); ++it) {
      size_t j = it->node->GetId();
      if( i < j ) {
        const Vec2D& posi = m_nodes[i].GetPosition();
        const Vec2D& posj = m_nodes[j].GetPosition();
        double d = posi.DistanceTo(posj);
        total += d * it->weight;
        total_weight += it->weight;
      }
    }
  }
  if( total_weight == 0.0 ) return 0.0;
  return total / total_weight;
}

double Kumpula2DMobileNDLDAging::AverageNodeDistance() const {
  double total = 0.0;
  size_t count = 0.0;
  for( size_t i=0; i < m_nodes.size(); i++) {
    for( size_t j=i+1; j < m_nodes.size(); j++) {
      const Vec2D& posi = m_nodes[i].GetPosition();
      const Vec2D& posj = m_nodes[j].GetPosition();
      total += posi.DistanceTo(posj);
      count += 1;
    }
  }
  return total / count;
}

void Kumpula2DMobileNDLDAging::LocalAndGlobalAttachement() {
  GA();
  // #pragma omp master
  // {
  //   std::cerr << "GA" << std::endl;
  //   for( size_t i=0; i < m_attachements.size(); i++) {
  //     std::cerr << m_attachements[i].first << ' ' << m_attachements[i].second << std::endl;
  //   }
  // }
  StrengthenEdges();
  LA();
  // #pragma omp master
  // {
  //   std::cerr << "LA" << std::endl;
  //   for( size_t i=0; i < m_attachements.size(); i++) {
  //     std::cerr << m_attachements[i].first << ' ' << m_attachements[i].second << std::endl;
  //   }
  //   std::cerr << "  enhancements" << std::endl;
  //   for( size_t i=0; i < m_enhancements.size(); i++) {
  //     std::cerr << m_enhancements[i].first << ' ' << m_enhancements[i].second << std::endl;
  //   }
  // }
  StrengthenEdges();
}

void Kumpula2DMobileNDLDAging::GA() {
  // Global attachment
  int thread_num = omp_get_thread_num();
  std::vector< std::pair<Node2D*,Node2D*> > local_attachements;

  const size_t size = m_nodes.size();
  #pragma omp for schedule(static)
  for( size_t i = 0; i < size; ++i) {
    Node2D * ni = &m_nodes[i];
    double r = Random::Rand01(thread_num);
    // #pragma omp critical
    // { std::cerr << "r:" << r << ", th: " << omp_get_thread_num() << std::endl; }
    if( ni->Degree() == 0 || r < m_p_jump ) {
      if( ni->Degree() == m_net_size - 1 ) { continue; }
      Node2D* nj = RandomSelectDependingOnDistance(ni);
      assert( ni->FindEdge(nj) == NULL );
      // #pragma omp critical
      // { std::cerr << "i,j:" << i << ',' << j << ", th: " << omp_get_thread_num() << std::endl; }
      AttachPair(ni, nj, local_attachements);
    }
  }

  #pragma omp critical
  {
    m_attachements.insert(m_attachements.end(), local_attachements.begin(), local_attachements.end());
  }
  #pragma omp barrier
}

void Kumpula2DMobileNDLDAging::LA() {
  // Local attachment
  int thread_num = omp_get_thread_num();
  std::vector< std::pair<Node2D*,Node2D*> > local_enhancements;
  std::vector< std::pair<Node2D*,Node2D*> > local_attachements;

  const size_t size = m_nodes.size();
  #pragma omp for schedule(static)
  for( size_t i=0; i < size; ++i) {
    // search first child
    Node2D* ni = &m_nodes[i];
    if( ni->Degree() == 0 ) { continue; }
    Edge* first_edge = ni->EdgeSelection(NULL);
    Node2D* first_child = first_edge->node;
    EnhancePair(ni, first_child, local_enhancements);

    // search second child
    if( first_child->Degree() == 1 ) { continue; }
    Edge* second_edge = first_child->EdgeSelection(ni);
    Node2D* second_child = second_edge->node;
    EnhancePair(first_child, second_child, local_enhancements);

    // connect i and second_child with p_tri
    if( ni->FindEdge(second_child) ) {
      EnhancePair(ni, second_child, local_enhancements);
    } else {
      if( Random::Rand01(thread_num) < m_p_tri ) {
        AttachPair(ni, second_child, local_attachements);
      }
    }
  }

  #pragma omp critical
  {
    m_enhancements.insert(m_enhancements.end(), local_enhancements.begin(), local_enhancements.end());
    m_attachements.insert(m_attachements.end(), local_attachements.begin(), local_attachements.end());
  }
  #pragma omp barrier
}

void Kumpula2DMobileNDLDAging::LinkDeletion() {
  std::map<size_t, std::vector<size_t> > linksToRemove;

  for( size_t i=0; i < m_net_size; i++) {
    const std::vector<Edge>& edges = m_nodes[i].GetEdges();
    for( std::vector<Edge>::const_iterator eit = edges.begin();
         eit != edges.end();
         eit++) {
      const Edge& edge = *eit;
    // for( const auto& edge : m_nodes[i].GetEdges() ) {
      size_t j = edge.node->GetId();
      if( j <= i ) { continue; }
      if( Random::Rand01( omp_get_thread_num() ) < m_p_ld ) {
        linksToRemove[i].push_back(j);
        linksToRemove[j].push_back(i);
        // std::cerr << i << ' ' << j << std::endl;
      }
    }
  }

  for( std::map<size_t, std::vector<size_t> >::const_iterator it = linksToRemove.begin();
       it != linksToRemove.end();
       ++it ) {
    size_t i = it->first;
    const std::vector<size_t>& vecj = it->second;
    for( std::vector<size_t>::const_iterator vit = vecj.begin();
         vit != vecj.end();
         ++vit ) {
      size_t j = *vit;
  //for( const auto& keyval : linksToRemove ) {
    //size_t i = keyval.first;
    //for( const auto& j : keyval.second ) {
      // std::cerr << i << ' ' << j << std::endl;
      // std::cerr << m_nodes[i].Degree() << std::endl;
      m_nodes[i].DeleteEdge( &m_nodes[j] );
      // std::cerr << m_nodes[i].Degree() << std::endl;
    }
  }
}

void Kumpula2DMobileNDLDAging::NodeDeletion() {
  assert( omp_get_thread_num() == 0 );
  for( size_t i=0; i < m_net_size; ++i) {
    if( Random::Rand01(0) < m_p_nd ) {
      DeleteNode(&m_nodes[i]);
      m_nodes[i].RandomizePosition();
    }
  }
}

void Kumpula2DMobileNDLDAging::DeleteNode(Node2D* ni) {
  const std::vector<Edge> edges = ni->GetEdges();
  for( std::vector<Edge>::const_iterator it = edges.begin(); it != edges.end(); ++it) {
    Node2D* nj = it->node;
    nj->DeleteEdge(ni);
  }
  ni->ClearAll();
}

void Kumpula2DMobileNDLDAging::NodeMovement() {
  if( m_mobility == 0.0 && m_noise == 0.0 ) {
    return;
  }

  const size_t size = m_nodes.size();

  #pragma omp for schedule(static)
  for( size_t i = 0; i < size; ++i) {
    m_nodes[i].Move(m_mobility, m_noise);
  }
}

void Kumpula2DMobileNDLDAging::NodeFlight() {

  const size_t size = m_nodes.size();
  const int thread_num = omp_get_thread_num();

  #pragma omp for schedule(static)
  for( size_t i = 0; i < size; ++i) {
    if( Random::Rand01(thread_num) < m_p_flight ) {
      m_nodes[i].Flight(m_beta);
    }
  }
}

void Kumpula2DMobileNDLDAging::StrengthenEdges() {
  // strengthen edges
  // #pragma omp barrier
  #pragma omp master
  {
  std::sort(m_attachements.begin(), m_attachements.end());
  m_attachements.erase( std::unique(m_attachements.begin(), m_attachements.end()), m_attachements.end() );

  for( AttachIt it = m_attachements.begin(); it != m_attachements.end(); ++it) {
    Node2D* ni = it->first;
    Node2D* nj = it->second;
    assert( ni->FindEdge(nj) == NULL );
    assert( nj->FindEdge(ni) == NULL );
    const double w_0 = 1.0;
    ni->AddEdge(nj, w_0);
    nj->AddEdge(ni, w_0);
  }
  }
  #pragma omp barrier

  const size_t en_size = m_enhancements.size();
  #pragma omp for schedule(static)
  for( size_t idx = 0; idx < en_size; idx++) {
    Node2D* ni = m_enhancements[idx].first;
    Node2D* nj = m_enhancements[idx].second;
    ni->EnhanceEdge(nj, m_delta);
    nj->EnhanceEdge(ni, m_delta);
  }

  #pragma omp master
  {
  m_attachements.clear();
  m_enhancements.clear();
  }
  #pragma omp barrier
}

void Kumpula2DMobileNDLDAging::AttachPair(Node2D* ni, Node2D* nj, std::vector< std::pair<Node2D*,Node2D*> >& attachements) {
  std::pair<Node2D*, Node2D*> node_pair = (ni<nj) ? std::make_pair(ni, nj) : std::make_pair(nj, ni);
  attachements.push_back(node_pair);
}

void Kumpula2DMobileNDLDAging::EnhancePair(Node2D * ni, Node2D* nj, std::vector< std::pair<Node2D*,Node2D*> >& enhancements) {
  std::pair<Node2D*, Node2D*> node_pair = (ni<nj) ? std::make_pair(ni, nj) : std::make_pair(nj, ni);
  enhancements.push_back(node_pair);
}

void Kumpula2DMobileNDLDAging::LinkAging() {
  for( size_t i=0; i < m_net_size; i++) {
    m_nodes[i].AgingEdge(m_aging, m_link_th);
  }
}

Node2D* Kumpula2DMobileNDLDAging::RandomSelectExceptFor(Node2D* ni) {
  int num_candidate = m_net_size - ni->Degree() - 1;
  int idx = static_cast<int>( Random::Rand01( omp_get_thread_num() ) * num_candidate );
  std::vector<int> exclude_index;
  const std::vector<Edge>& edges = ni->GetEdges();
  for( std::vector<Edge>::const_iterator it = edges.begin(); it != edges.end(); ++it) {
    exclude_index.push_back( (*it).node->GetId() );
  }
  exclude_index.push_back(ni->GetId());
  std::sort(exclude_index.begin(), exclude_index.end());
  assert( exclude_index.size() == ni->Degree() + 1 );

  for( std::vector<int>::iterator it = exclude_index.begin(); it != exclude_index.end(); ++it) {
    // std::cout << *it << ' ' << idx << std::endl;
    if( idx >= *it ) { idx += 1; }
    else { break; }
  }
  assert( idx < static_cast<int>(m_net_size) );
  return &m_nodes[idx];
}

Node2D* Kumpula2DMobileNDLDAging::RandomSelectDependingOnDistance(Node2D* ni) {
  // calculate exclude_index
  std::vector<int> exclude_index;
  const std::vector<Edge>& edges = ni->GetEdges();
  for( std::vector<Edge>::const_iterator it = edges.begin(); it != edges.end(); ++it) {
    exclude_index.push_back( (*it).node->GetId() );
  }
  exclude_index.push_back(ni->GetId());
  std::sort(exclude_index.begin(), exclude_index.end());
  assert( exclude_index.size() == ni->Degree() + 1 );

  // std::cout << "i: " << i << std::endl;

  // calculate probs
  std::vector<double> probs(m_net_size, 0.0);
  double prob_sum = 0.0;
  for( size_t j=0; j < m_net_size; j++) {
    if( ! std::binary_search(exclude_index.begin(), exclude_index.end(), j) ) {
      assert(ni->GetId() != j);
      double prob = std::pow( ni->DistanceTo(m_nodes[j]), -m_alpha );
      prob_sum += prob;
    }
    probs[j] = prob_sum;
    // std::cout << j << ' ' << probs[j] << std::endl;
  }

  double r = prob_sum * Random::Rand01( omp_get_thread_num() );
  std::vector<double>::iterator found = std::upper_bound(probs.begin(), probs.end(), r);
  int index = found - probs.begin();
  // std::cout << "r: " << r << ", index: " << index << std::endl;
  assert(index >= 0 && index < static_cast<int>(m_net_size) && ni != &m_nodes[index] );
  return &m_nodes[index];
}
