---
name: vmas-simulator-guide
description: "Vectorized multi-agent reinforcement learning simulator"
metadata:
  openclaw:
    emoji: "🎮"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["multi-agent RL", "VMAS", "simulator", "reinforcement learning", "vectorized", "cooperative"]
    source: "https://github.com/proroklab/VectorizedMultiAgentSimulator"
---

# VMAS: Vectorized Multi-Agent Simulator Guide

## Overview

VMAS is a vectorized simulator for multi-agent reinforcement learning (MARL) that runs thousands of parallel environments on GPU via PyTorch. It provides a diverse set of 2D cooperative, competitive, and mixed scenarios for benchmarking multi-agent algorithms. Orders of magnitude faster than CPU-based simulators, enabling rapid research iteration on multi-agent coordination problems.

## Installation

```bash
pip install vmas
```

## Quick Start

```python
import vmas

# Create vectorized environment
env = vmas.make_env(
    scenario="simple_spread",
    num_envs=1024,         # Parallel environments
    num_agents=3,
    device="cuda",         # GPU acceleration
    continuous_actions=True,
)

# Environment loop
obs = env.reset()
for step in range(100):
    # Random actions for demonstration
    actions = [env.action_space[i].sample()
               for i in range(env.n_agents)]

    obs, rewards, dones, infos = env.step(actions)
    # obs: list of [num_envs, obs_dim] tensors
    # rewards: list of [num_envs] tensors
```

## Scenarios

| Scenario | Type | Agents | Description |
|----------|------|--------|-------------|
| **simple_spread** | Cooperative | 3 | Cover N landmarks |
| **simple_tag** | Competitive | 4 | Predator-prey |
| **transport** | Cooperative | 4 | Move package to goal |
| **wheel** | Cooperative | 4 | Coordination on wheel |
| **flocking** | Cooperative | 5+ | Reynolds flocking |
| **discovery** | Cooperative | 3 | Explore and discover |
| **navigation** | Mixed | N | Multi-agent navigation |

## Integration with MARL Libraries

```python
# With TorchRL
from torchrl.envs import VmasEnv

env = VmasEnv(
    scenario="simple_spread",
    num_envs=512,
    device="cuda",
)

# With RLlib
from ray.rllib.env import MultiAgentEnv
# VMAS provides RLlib-compatible wrapper

# With CleanRL / custom training
import torch

env = vmas.make_env("transport", num_envs=2048, device="cuda")
obs = env.reset()

# All tensors on GPU — train directly without CPU transfer
policy_output = policy_network(obs[0])  # Agent 0 observations
```

## Custom Scenarios

```python
from vmas import Scenario, Agent, World, Landmark

class MyScenario(Scenario):
    def make_world(self, batch_dim, device):
        world = World(batch_dim=batch_dim, device=device)
        world.add_agent(Agent(name="agent_0"))
        world.add_agent(Agent(name="agent_1"))
        world.add_landmark(Landmark(name="goal"))
        return world

    def reset_world(self, env, world):
        # Randomize positions
        for agent in world.agents:
            agent.set_pos(torch.rand(env.batch_dim, 2) * 2 - 1)

    def reward(self, agent, world):
        # Distance to goal
        goal = world.landmarks[0]
        return -torch.linalg.norm(agent.state.pos - goal.state.pos,
                                   dim=-1)

# Register and use
env = vmas.make_env(MyScenario(), num_envs=512)
```

## Use Cases

1. **MARL research**: Benchmark multi-agent algorithms
2. **Cooperative learning**: Study emergent coordination
3. **Scalability testing**: GPU-accelerated parallel training
4. **Custom scenarios**: Design domain-specific multi-agent tasks
5. **Education**: Teach multi-agent RL concepts

## References

- [VMAS GitHub](https://github.com/proroklab/VectorizedMultiAgentSimulator)
- [VMAS Paper](https://arxiv.org/abs/2207.03530)
- [BenchMARL](https://github.com/facebookresearch/BenchMARL)
