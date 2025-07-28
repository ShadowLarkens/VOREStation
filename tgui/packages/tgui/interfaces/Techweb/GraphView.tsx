import dagre from '@dagrejs/dagre';
import { useEffect, useState } from 'react';
import { Box, Button, InfinitePlane } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';
import { resolveAsset } from '../../assets';
import { useTechWebRoute } from './hooks';

type ResearchJson = {
  nodes: {
    v: string;
    name: string;
  }[];
  edges: {
    v: string;
    w: string;
  }[];
};

type TechwebGraphNode = {
  v: string;
  label: string;
  x: number;
  y: number;
};

type TechwebGraphEdge = {
  v: string;
  w: string;
  v_label: string;
  w_label: string;
  points: {
    x: number;
    y: number;
  }[];
};

export const TechwebGraphView = (props) => {
  const [nodes, setNodes] = useState<TechwebGraphNode[]>();
  const [edges, setEdges] = useState<TechwebGraphEdge[]>();
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  useEffect(() => {
    const render = async () => {
      const data: ResearchJson = await fetchRetry(
        resolveAsset('research_json.json'),
      ).then((response) => response.json());

      const g = new dagre.graphlib.Graph();
      g.setGraph({
        ranker: 'longest-path',
        ranksep: 100,
      });
      g.setDefaultEdgeLabel(() => {
        return {};
      });

      for (const node of data.nodes) {
        g.setNode(node.v, { label: node.v, width: 200, height: 20 });
      }

      for (const edge of data.edges) {
        g.setEdge(edge.v, edge.w);
      }

      dagre.layout(g);

      const nodes = g.nodes().map((v) => {
        const node = g.node(v);
        return {
          v: v,
          label: node.label || v,
          x: node.x,
          y: node.y,
        };
      });

      const edges = g.edges().map((e) => {
        const edge = g.edge(e);
        const nodeV = g.node(e.v);
        const nodeW = g.node(e.w);
        return {
          v: e.v,
          w: e.w,
          v_label: nodeV.label || e.v,
          w_label: nodeW.label || e.w,
          points: edge.points,
        };
      });

      setNodes(nodes);
      setEdges(edges);
    };
    render();
  }, []);

  return (
    <InfinitePlane
      backgroundImage={resolveAsset('grid_background.png')}
      imageWidth={900}
      initialLeft={100}
      initialTop={-50}
    >
      {nodes?.map((node) => (
        <Button
          width="200px"
          height="20px"
          backgroundColor="black"
          key={node.v}
          position="absolute"
          left={`${node.x - 100}px`}
          top={`${node.y - 10}px`}
          textAlign="center"
          id={node.v}
          onClick={() =>
            setTechwebRoute({ route: 'details', selectedNode: node.v })
          }
        >
          {node.label}
        </Button>
      ))}
      <svg
        width="100%"
        height="100%"
        style={{
          position: 'absolute',
          zIndex: -1,
          overflow: 'visible',
        }}
      >
        <g>
          {edges?.map((edge) => {
            const first = edge.points[0];
            const last = edge.points[edge.points.length - 1];

            const MAX_LENGTH_BEFORE_JUMP = 600;
            const JUMP_X = 20;
            const JUMP_Y = 20;
            const JUMP_UPPER_X = 20;
            const JUMP_UPPER_Y = -40;

            if (Math.abs(first.x - last.x) > MAX_LENGTH_BEFORE_JUMP) {
              const first_path = `M ${first.x} ${first.y} L ${first.x + JUMP_X} ${first.y + JUMP_Y}`;
              const last_path = `M ${last.x} ${last.y} L ${last.x + JUMP_UPPER_X} ${last.y + JUMP_UPPER_Y}`;

              return (
                <g key={edge.v + edge.w}>
                  <g
                    cursor="pointer"
                    onClick={() =>
                      setTechwebRoute({
                        route: 'details',
                        selectedNode: edge.w,
                      })
                    }
                  >
                    <path d={first_path} stroke="#3639c4" strokeWidth={2} />
                    <rect
                      fill="#3639c4"
                      x={first.x + JUMP_X}
                      y={first.y + JUMP_Y}
                      width={edge.w_label.length * 10}
                      height={20}
                      rx="5px"
                    />
                    <text
                      x={first.x + JUMP_X + 5}
                      y={first.y + JUMP_Y + 15}
                      fill="white"
                    >
                      {edge.w_label}
                    </text>
                  </g>
                  <g
                    cursor="pointer"
                    onClick={() =>
                      setTechwebRoute({
                        route: 'details',
                        selectedNode: edge.v,
                      })
                    }
                  >
                    <path d={last_path} stroke="#3684c4ff" strokeWidth={2} />
                    <rect
                      fill="#3684c4ff"
                      x={last.x + JUMP_UPPER_X}
                      y={last.y + JUMP_UPPER_Y}
                      width={edge.v_label.length * 10}
                      height={20}
                      rx="5px"
                    />
                    <text
                      x={last.x + JUMP_UPPER_X + 5}
                      y={last.y + JUMP_UPPER_Y + 15}
                      fill="white"
                    >
                      {edge.v_label}
                    </text>
                  </g>
                </g>
              );
            }

            let path = ``;
            let i = 0;
            for (const point of edge.points) {
              if (i === 0) {
                path += `M ${point.x} ${point.y} `;
              }
              path += `L ${point.x} ${point.y} `;
              if (i !== 0) {
                path += `M ${point.x} ${point.y} `;
              }
              i++;
            }

            return (
              <path
                key={edge.v + edge.w}
                d={path}
                stroke="white"
                strokeWidth={2}
              />
            );
          })}
        </g>
      </svg>
    </InfinitePlane>
  );
};
