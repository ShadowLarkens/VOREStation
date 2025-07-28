import dagre from '@dagrejs/dagre';
import { useEffect, useState } from 'react';
import { Box, InfinitePlane } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';
import { resolveAsset } from '../../assets';

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
  points: {
    x: number;
    y: number;
  }[];
};

export const TechwebGraphView = (props) => {
  const [nodes, setNodes] = useState<TechwebGraphNode[]>();
  const [edges, setEdges] = useState<TechwebGraphEdge[]>();

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
        <Box
          width="200px"
          height="20px"
          backgroundColor="black"
          key={node.v}
          position="absolute"
          left={`${node.x - 100}px`}
          top={`${node.y - 10}px`}
          textAlign="center"
        >
          {node.label}
        </Box>
      ))}
      <svg
        width="100%"
        height="100%"
        style={{
          position: 'absolute',
          pointerEvents: 'none',
          zIndex: -1,
          overflow: 'visible',
        }}
      >
        <g>
          {edges?.map((edge) => {
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
