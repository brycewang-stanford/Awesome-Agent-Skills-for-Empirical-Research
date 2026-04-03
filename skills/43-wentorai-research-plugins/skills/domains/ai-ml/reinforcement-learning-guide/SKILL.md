---
name: reinforcement-learning-guide
description: "Reinforcement learning fundamentals, algorithms, and research"
metadata:
  openclaw:
    emoji: "🤖"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["reinforcement learning", "machine learning", "deep learning", "neural network"]
    source: "wentor-research-plugins"
---

# Reinforcement Learning Guide

Understand and implement reinforcement learning algorithms from tabular methods through deep RL, including policy gradients, actor-critic, and model-based approaches.

## RL Fundamentals

### The RL Framework

An agent interacts with an environment to maximize cumulative reward:

```
Agent                     Environment
  |                           |
  |--- action a_t ---------->|
  |                           |--- next state s_{t+1}
  |<-- reward r_t, state s_t |--- reward r_{t+1}
  |                           |
```

| Concept | Symbol | Definition |
|---------|--------|-----------|
| State | s | Observation of the environment |
| Action | a | Decision made by the agent |
| Reward | r | Scalar feedback signal |
| Policy | pi(a\|s) | Mapping from states to actions |
| Value function | V(s) | Expected cumulative reward from state s |
| Q-function | Q(s, a) | Expected cumulative reward from (s, a) |
| Discount factor | gamma | Weight of future vs. immediate rewards (0-1) |
| Return | G_t | Sum of discounted future rewards from time t |

### Key Equations

```
# Return (discounted cumulative reward)
G_t = r_t + gamma * r_{t+1} + gamma^2 * r_{t+2} + ...

# Bellman equation for V
V(s) = E[r + gamma * V(s') | s]

# Bellman equation for Q
Q(s, a) = E[r + gamma * max_a' Q(s', a') | s, a]

# Policy gradient theorem
gradient J(theta) = E[gradient log pi_theta(a|s) * Q(s, a)]
```

## Algorithm Taxonomy

| Category | Algorithm | Key Idea | On/Off Policy |
|----------|-----------|----------|--------------|
| **Value-based** | Q-Learning | Learn Q(s,a), act greedily | Off-policy |
| | DQN | Q-Learning + neural net + replay buffer | Off-policy |
| | Double DQN | Two networks to reduce overestimation | Off-policy |
| | Dueling DQN | Separate value and advantage streams | Off-policy |
| **Policy gradient** | REINFORCE | Monte Carlo policy gradient | On-policy |
| | PPO | Clipped surrogate objective | On-policy |
| | TRPO | Trust region constraint | On-policy |
| **Actor-Critic** | A2C/A3C | Advantage actor-critic (parallel) | On-policy |
| | SAC | Maximum entropy + off-policy AC | Off-policy |
| | TD3 | Twin delayed DDPG | Off-policy |
| **Model-based** | Dreamer | World model + imagination | On-policy |
| | MBPO | Model-based policy optimization | Off-policy |
| | MuZero | Learned model + planning (MCTS) | Off-policy |

## Implementation: DQN

```python
import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
from collections import deque
import random

class QNetwork(nn.Module):
    def __init__(self, state_dim, action_dim, hidden_dim=128):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(state_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, action_dim)
        )

    def forward(self, x):
        return self.net(x)

class DQNAgent:
    def __init__(self, state_dim, action_dim, lr=1e-3, gamma=0.99,
                 epsilon=1.0, epsilon_decay=0.995, epsilon_min=0.01,
                 buffer_size=10000, batch_size=64):
        self.action_dim = action_dim
        self.gamma = gamma
        self.epsilon = epsilon
        self.epsilon_decay = epsilon_decay
        self.epsilon_min = epsilon_min
        self.batch_size = batch_size

        self.q_network = QNetwork(state_dim, action_dim)
        self.target_network = QNetwork(state_dim, action_dim)
        self.target_network.load_state_dict(self.q_network.state_dict())
        self.optimizer = optim.Adam(self.q_network.parameters(), lr=lr)

        self.replay_buffer = deque(maxlen=buffer_size)

    def select_action(self, state):
        if random.random() < self.epsilon:
            return random.randint(0, self.action_dim - 1)
        with torch.no_grad():
            q_values = self.q_network(torch.FloatTensor(state))
            return q_values.argmax().item()

    def store_transition(self, state, action, reward, next_state, done):
        self.replay_buffer.append((state, action, reward, next_state, done))

    def train_step(self):
        if len(self.replay_buffer) < self.batch_size:
            return 0.0

        batch = random.sample(self.replay_buffer, self.batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)

        states = torch.FloatTensor(np.array(states))
        actions = torch.LongTensor(actions)
        rewards = torch.FloatTensor(rewards)
        next_states = torch.FloatTensor(np.array(next_states))
        dones = torch.FloatTensor(dones)

        # Current Q values
        q_values = self.q_network(states).gather(1, actions.unsqueeze(1)).squeeze()

        # Target Q values (Double DQN variant)
        with torch.no_grad():
            best_actions = self.q_network(next_states).argmax(1)
            next_q = self.target_network(next_states).gather(1, best_actions.unsqueeze(1)).squeeze()
            targets = rewards + self.gamma * next_q * (1 - dones)

        loss = nn.MSELoss()(q_values, targets)
        self.optimizer.zero_grad()
        loss.backward()
        self.optimizer.step()

        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)
        return loss.item()

    def update_target(self):
        self.target_network.load_state_dict(self.q_network.state_dict())
```

## Implementation: PPO

```python
class PPOAgent:
    def __init__(self, state_dim, action_dim, lr=3e-4, gamma=0.99,
                 lam=0.95, clip_ratio=0.2, epochs=10):
        self.gamma = gamma
        self.lam = lam
        self.clip_ratio = clip_ratio
        self.epochs = epochs

        self.actor = nn.Sequential(
            nn.Linear(state_dim, 64), nn.Tanh(),
            nn.Linear(64, 64), nn.Tanh(),
            nn.Linear(64, action_dim), nn.Softmax(dim=-1)
        )
        self.critic = nn.Sequential(
            nn.Linear(state_dim, 64), nn.Tanh(),
            nn.Linear(64, 64), nn.Tanh(),
            nn.Linear(64, 1)
        )
        self.optimizer = optim.Adam(
            list(self.actor.parameters()) + list(self.critic.parameters()), lr=lr
        )

    def compute_gae(self, rewards, values, dones):
        """Generalized Advantage Estimation."""
        advantages = []
        gae = 0
        for t in reversed(range(len(rewards))):
            next_value = values[t + 1] if t + 1 < len(values) else 0
            delta = rewards[t] + self.gamma * next_value * (1 - dones[t]) - values[t]
            gae = delta + self.gamma * self.lam * (1 - dones[t]) * gae
            advantages.insert(0, gae)
        return torch.FloatTensor(advantages)

    def update(self, states, actions, old_log_probs, rewards, dones):
        values = self.critic(states).squeeze().detach().numpy()
        advantages = self.compute_gae(rewards, values, dones)
        returns = advantages + torch.FloatTensor(values[:len(advantages)])
        advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)

        for _ in range(self.epochs):
            probs = self.actor(states)
            dist = torch.distributions.Categorical(probs)
            new_log_probs = dist.log_prob(actions)
            entropy = dist.entropy().mean()

            ratio = (new_log_probs - old_log_probs).exp()
            clipped = torch.clamp(ratio, 1 - self.clip_ratio, 1 + self.clip_ratio)
            actor_loss = -torch.min(ratio * advantages, clipped * advantages).mean()

            critic_loss = nn.MSELoss()(self.critic(states).squeeze(), returns)

            loss = actor_loss + 0.5 * critic_loss - 0.01 * entropy
            self.optimizer.zero_grad()
            loss.backward()
            self.optimizer.step()
```

## Research Environments

| Environment | Domain | Complexity | Key Paper |
|-------------|--------|-----------|-----------|
| Gymnasium (ex-Gym) | Classic control, Atari | Low-High | Brockman et al., 2016 |
| MuJoCo | Continuous control, robotics | Medium-High | Todorov et al., 2012 |
| DMControl | Continuous control from pixels | High | Tassa et al., 2018 |
| ProcGen | Procedurally generated games | High (generalization) | Cobbe et al., 2020 |
| Minigrid | Grid-world navigation | Low-Medium | Chevalier-Boisvert et al. |
| Isaac Gym | GPU-accelerated physics sim | High | Makoviychuk et al., 2021 |
| NetHack | Complex roguelike game | Very High | Kuttler et al., 2020 |

## Top Venues

| Venue | Type | Focus |
|-------|------|-------|
| NeurIPS | Conference | Broad ML including RL |
| ICML | Conference | Broad ML including RL |
| ICLR | Conference | Representation learning, deep RL |
| AAAI | Conference | Broad AI |
| CoRL | Conference | Robot learning |
| JMLR | Journal | Broad ML (open access) |
| L4DC | Conference | Learning for dynamics and control |

## Key Research Directions (2024-2025)

1. **RLHF / RLAIF**: RL from human or AI feedback for LLM alignment
2. **Offline RL**: Learning from pre-collected datasets without environment interaction
3. **Foundation models for control**: Using pre-trained LLMs/VLMs as world models or planners
4. **Multi-agent RL**: Cooperative and competitive settings with communication
5. **Safe RL**: Constrained optimization to ensure safety during training and deployment
6. **Sample-efficient RL**: Reducing the gap between model-free and model-based sample complexity
