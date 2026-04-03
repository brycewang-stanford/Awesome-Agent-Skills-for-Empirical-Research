# Identification Proof Templates

LaTeX and plain-language templates for writing formal identification propositions. Referenced from the main SKILL.md.

---

## LaTeX Template

Use this template for writing an identification proposition in a paper or theory appendix. Adapt the assumptions to your model.

```latex
\begin{assumption}[Model restrictions]\label{ass:model}
  \begin{enumerate}[(i)]
    \item (Structural equation) $Y_i = g(X_i, \varepsilon_i;\, \theta_0)$ a.s.
    \item (Exogeneity) $\mathbb{E}[\varepsilon_i \mid Z_i] = 0$.
    \item (Relevance) $\mathbb{E}[X_i Z_i'] = \Pi$ with $\mathrm{rank}(\Pi) = K$.
    \item (Support) $Z_i$ has full support on $\mathcal{Z} \subseteq \mathbb{R}^L$.
    \item (Compactness) $\Theta \subset \mathbb{R}^K$ is compact.
    \item (Continuity) $\mathbb{E}[m(X_i;\theta)]$ is continuously differentiable in $\theta$.
  \end{enumerate}
\end{assumption}

\begin{proposition}[Identification of $\theta_0$]\label{prop:id}
  Under Assumption~\ref{ass:model}(i)--(vi), $\theta_0$ is the unique element of
  $\Theta$ satisfying $\mathbb{E}[m(X_i;\theta_0)] = 0$.
\end{proposition}

\begin{proof}
  \textbf{Step 1 (Observational implications).}
  Show that the structural equation implies a set of moment conditions
  $\mathbb{E}[m(X_i;\theta_0)] = 0$ that are functions of the observable distribution.
  [Derivation here.]

  \textbf{Step 2 (Rank condition implies local injectivity).}
  The Jacobian $G(\theta) \equiv \partial\mathbb{E}[m(X;\theta)]/\partial\theta'$
  has full column rank $K$ at $\theta_0$ by Assumption~\ref{ass:model}(iii).
  By the implicit function theorem, $\theta_0$ is the unique solution in a
  neighborhood $\mathcal{N}(\theta_0)$.

  \textbf{Step 3 (Global uniqueness).}
  [Argue that $\theta_0$ is the unique global solution, e.g., by convexity
  of the moment function, or by a direct argument that $P_{\theta_1} = P_{\theta_2}
  \implies \theta_1 = \theta_2$ over $\Theta$.]

  Combining Steps 1--3, $\theta_0$ is the unique element of $\Theta$ consistent
  with the observable distribution $P_{\theta_0}$. \hfill$\square$
\end{proof}
```

---

## Plain-Language Structure

When writing for a paper (not a theory appendix), use the same logical structure in prose:

1. **State the target**: "We seek to identify the price coefficient $\alpha$ in the demand equation..."
2. **State the model and observables**: "The model implies market shares $s_j$ are related to mean utilities $\delta_j(\alpha)$ by..."
3. **State the identifying variation**: "Identification comes from variation in BLP instruments — sums of rival product characteristics — which shift prices but are excluded from the demand equation..."
4. **State the key assumption**: "We assume the instruments satisfy the exclusion restriction: $\mathbb{E}[Z_j \xi_j] = 0$, where $\xi_j$ is the demand shock..."
5. **State the identification result**: "Under the rank condition [cite], the parameter vector $\alpha$ is uniquely identified from the system of first-order conditions..."
6. **State regularity conditions**: "This identification requires: (i) $\Theta$ compact; (ii) $s(\delta)$ continuous in $\delta$; (iii) full rank instruments..."
