#ifndef NODE_HPP
#define NODE_HPP

#include <cassert>
#include <iostream>
#include <vector>
#include <sstream>
#include "random.hpp"

class Node2D;

//=================================================
class Edge {
public:
  Edge(Node2D* n, double w0) {
    node = n;
    weight = w0;
  }
  Node2D* node;
  double weight;
};

//=================================================
class Vec2D {   // 2D vector with periodic boundary condition
public:
  Vec2D() : x(0.0), y(0.0) {};
  Vec2D(double _x, double _y) : x(_x), y(_y) {};
  double GetX() const { return x; }
  double GetY() const { return y; }
  void Set(double _x, double _y) { x = _x; y = _y; }
  std::string toString() const {
    std::ostringstream oss;
    oss << "(" << x << "," << y << ")";
    return oss.str();
  }
  Vec2D RelativeDir(const Vec2D& other) const {
    double dx = other.x - x;
    if( dx >= 0.5 ) { dx -= 1.0; }
    else if( dx < -0.5 ) { dx += 1.0; }
    assert( dx < 0.5 || dx >= -0.5 );
    double dy = other.y - y;
    if( dy >= 0.5 ) { dy -= 1.0; }
    else if( dy < -0.5 ) { dy += 1.0; }
    assert( dy < 0.5 || dy >= -0.5 );
    return Vec2D(dx, dy);
  }
  double DistanceTo(const Vec2D& other) const {
    Vec2D dir = RelativeDir(other);
    return std::sqrt(dir.x*dir.x + dir.y*dir.y);
  }
  Vec2D operator+(const Vec2D& other) const {
    return Vec2D(x+other.x, y+other.y);
  }
  Vec2D operator*(double d) const {
    return Vec2D(x*d, y*d);
  }
  void MoveToward(const Vec2D& direction) {
    x += direction.x;
    y += direction.y;
    if( x >= 1.0 || x < 0.0 ) { x -= std::floor(x); }
    if( y >= 1.0 || y < 0.0 ) { y -= std::floor(y); }
    assert( x >= 0.0 && x < 1.0);
    assert( y >= 0.0 && y < 1.0);
  }
private:
  double x, y;
};

//=================================================
class Node2D {
public:
  Node2D(size_t id) :
    m_id(id),
    position() {
      double x = Random::Rand01(0); double y = Random::Rand01(0);
      position.Set(x, y);
    }
  size_t GetId() const { return m_id; }
  const Vec2D& GetPosition() const { return position; }

  // randomly select edge with the probability proportional to its weight
  // if parent_node is not NULL, the parent node is not included in the candidates
  // when parent_node_id is NULL, the edge is selected from all the connecting edges
  Edge* EdgeSelection(Node2D* parent_node);
  size_t Degree() const { return m_edges.size(); }
  double Strength() const;
  Edge* FindEdge(Node2D* nj);  // return the pointer to edge. If not found, return NULL;
  void AddEdge(Node2D* nj, double initial_weight);
  void EnhanceEdge(Node2D* nj, double delta);
  void DeleteEdge(Node2D* nj);
  void AgingEdge(double aging_factor, double threshold);
  const std::vector<Edge>& GetEdges() const { return m_edges; }
  void ClearAll() { m_edges.clear(); }
  double DistanceTo( const Node2D & other ) const;
  void Move(double mobility, double noise);
  void Flight(double beta);
  void RandomizePosition();
protected:
  size_t m_id;
  std::vector<Edge> m_edges;
  typedef std::vector<Edge>::iterator EdgeIt;
  typedef std::vector<Edge>::const_iterator CEdgeIt;
  Vec2D position;
};

#endif
