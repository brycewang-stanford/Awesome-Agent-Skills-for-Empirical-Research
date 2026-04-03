#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

IGNORE_DIRS = {
    '.git', '.hg', '.svn', '.venv', 'venv', 'node_modules', '__pycache__',
    '.mypy_cache', '.pytest_cache', '.ruff_cache', '.idea', '.vscode',
    'dist', 'build', 'checkpoints', 'checkpoint', 'cache', '.cache', '.claude',
    'temp', 'tmp', '.tmp'
}
MAX_LIST_ITEMS = 40
MAX_SYNC_PATHS = 24
RECENT_BULLET_LIMIT = 8
CODE_EXTENSIONS = {
    '.py', '.ipynb', '.sh', '.bash', '.zsh', '.js', '.ts', '.tsx', '.jsx',
    '.rs', '.go', '.java', '.cpp', '.cc', '.c', '.h', '.hpp', '.yaml', '.yml',
    '.toml', '.json', '.ini', '.cfg', '.conf'
}
DOC_EXTENSIONS = {'.md', '.txt', '.rst'}
RESULT_EXTENSIONS = {'.csv', '.json', '.md', '.txt', '.log'}
SYNC_TOPICS = ('plan', 'literature', 'experiments', 'results', 'writing', 'meetings')
DEFAULT_NOTE_LANGUAGE = 'en'
NOTE_LANGUAGE_ENV_VARS = ('OBSIDIAN_NOTE_LANGUAGE',)
NOTE_LANGUAGE_ALIASES = {
    'en': 'en',
    'en-us': 'en',
    'en-gb': 'en',
    'english': 'en',
    'zh': 'zh-CN',
    'zh-cn': 'zh-CN',
    'zh-hans': 'zh-CN',
    'cn': 'zh-CN',
    'chinese': 'zh-CN',
}
SUPPORTED_NOTE_LANGUAGES = ('en', 'zh-CN')
NOTE_KIND_FOLDERS = {
    'knowledge': 'Knowledge',
    'paper': 'Papers',
    'experiment': 'Experiments',
    'result': 'Results',
    'writing': 'Writing',
    'daily': 'Daily',
}
INDEX_NOTE_REL_PATHS = (
    '00-Hub.md',
    '01-Plan.md',
    'Knowledge/Source-Inventory.md',
    'Knowledge/Codebase-Overview.md',
    'Results/Figure-and-CSV-Index.md',
)
SECTION_LABELS = {
    'recent_progress': {'en': 'Recent Progress', 'zh-CN': '近期进展'},
    'active_goals': {'en': 'Active Goals', 'zh-CN': '当前目标'},
    'active_tasks': {'en': 'Active Tasks', 'zh-CN': '当前任务'},
    'open_questions': {'en': 'Open Questions', 'zh-CN': '待解决问题'},
    'focus': {'en': 'Focus', 'zh-CN': '关注重点'},
    'planned_tasks': {'en': 'Planned Tasks', 'zh-CN': '计划任务'},
    'notes': {'en': 'Notes', 'zh-CN': '备注'},
    'current_question': {'en': 'Current Question', 'zh-CN': '当前问题'},
    'hypotheses': {'en': 'Hypotheses', 'zh-CN': '研究假设'},
    'open_experiments': {'en': 'Open Experiments', 'zh-CN': '进行中的实验'},
    'recent_results': {'en': 'Recent Results', 'zh-CN': '近期结果'},
    'recent_sync_status': {'en': 'Recent Sync Status', 'zh-CN': '最近同步状态'},
    'repository_signals': {'en': 'Repository Signals', 'zh-CN': '仓库信号'},
    'sync_queue': {'en': 'Sync Queue', 'zh-CN': '同步队列'},
    'sync_updates': {'en': 'Sync Updates', 'zh-CN': '同步更新'},
}
TEXT = {
    'none': {'en': 'None', 'zh-CN': '无'},
    'none_detected': {'en': 'None detected', 'zh-CN': '未检测到内容'},
    'source_inventory_title': {'en': 'Source Inventory - {repo_name}', 'zh-CN': '资料清单 - {repo_name}'},
    'source_inventory_h1': {'en': 'Source Inventory', 'zh-CN': '资料清单'},
    'source_inventory_imported_from': {'en': 'Imported from `{repo_root}`.', 'zh-CN': '导入来源：`{repo_root}`。'},
    'markdown_sources': {'en': 'Markdown Sources', 'zh-CN': 'Markdown 资料'},
    'code_and_config_files': {'en': 'Code and Config Files', 'zh-CN': '代码与配置文件'},
    'result_and_report_files': {'en': 'Result and Report Files', 'zh-CN': '结果与报告文件'},
    'codebase_overview_title': {'en': 'Codebase Overview - {repo_name}', 'zh-CN': '代码库概览 - {repo_name}'},
    'codebase_overview_h1': {'en': 'Codebase Overview', 'zh-CN': '代码库概览'},
    'repository_root': {'en': 'Repository root', 'zh-CN': '仓库根目录'},
    'detected_languages': {'en': 'Detected languages', 'zh-CN': '检测到的语言'},
    'research_project_score': {'en': 'Research-project score', 'zh-CN': '科研项目评分'},
    'matched_signals': {'en': 'Matched signals', 'zh-CN': '命中的信号'},
    'top_level_directories': {'en': 'Top-level directories', 'zh-CN': '顶层目录'},
    'key_entry_files': {'en': 'Key entry files', 'zh-CN': '关键入口文件'},
    'suggested_knowledge_targets': {'en': 'Suggested knowledge targets', 'zh-CN': '建议沉淀的知识对象'},
    'suggested_target_1': {
        'en': 'Link experiment scripts to `Experiments/` notes.',
        'zh-CN': '将实验脚本关联到 `Experiments/` 笔记。',
    },
    'suggested_target_2': {
        'en': 'Link evaluation scripts and generated reports to canonical `Results/` notes and `Results/Reports/` when a full retrospective exists.',
        'zh-CN': '将评测脚本和生成报告关联到规范的 `Results/` 与 `Results/Reports/` 笔记。',
    },
    'suggested_target_3': {
        'en': 'Keep planning and TODO updates synchronized with `01-Plan.md` and `Daily/`.',
        'zh-CN': '将计划与 TODO 的更新同步到 `01-Plan.md` 和 `Daily/`。',
    },
    'project_label': {'en': 'Project', 'zh-CN': '项目'},
    'canvas_description': {
        'en': 'Use this canvas to connect papers, concepts, experiments, and results.',
        'zh-CN': '使用这个画布连接论文、概念、实验与结果。',
    },
    'today_daily_note': {'en': "Today's Daily Note", 'zh-CN': '今日日志'},
    'hub_mission_heading': {'en': 'Mission', 'zh-CN': '项目使命'},
    'hub_mission_body': {
        'en': 'Keep the project grounded in a small set of research-facing folders: Knowledge, Papers, Experiments, Results, Results/Reports, Writing, and Daily.',
        'zh-CN': '让项目稳定沉淀在少量研究导向文件夹中：Knowledge、Papers、Experiments、Results、Results/Reports、Writing 和 Daily。',
    },
    'hub_core_index': {'en': 'Core Index', 'zh-CN': '核心索引'},
    'hub_folder_layout': {'en': 'Folder Layout', 'zh-CN': '目录结构'},
    'hub_initialized': {
        'en': 'Project knowledge base initialized at {timestamp}.',
        'zh-CN': '项目知识库已于 {timestamp} 初始化。',
    },
    'plan_title_prefix': {'en': 'Plan', 'zh-CN': '计划'},
    'plan_h1': {'en': 'Plan', 'zh-CN': '计划'},
    'plan_goal_1': {'en': 'Clarify current research question.', 'zh-CN': '澄清当前研究问题。'},
    'plan_goal_2': {
        'en': 'Keep experiments, results, and writing synchronized with the vault.',
        'zh-CN': '保持实验、结果与写作内容和知识库同步。',
    },
    'plan_task_1': {'en': 'Review imported project structure', 'zh-CN': '检查已导入的项目结构'},
    'plan_task_2': {'en': 'Fill in project hypothesis', 'zh-CN': '补全当前研究假设'},
    'plan_task_3': {'en': 'Add current experiment queue', 'zh-CN': '添加当前实验队列'},
    'plan_question_1': {'en': 'What is the current milestone?', 'zh-CN': '当前里程碑是什么？'},
    'plan_question_2': {'en': 'Which experiments are blocked?', 'zh-CN': '哪些实验处于阻塞状态？'},
    'plan_question_3': {
        'en': 'Which papers or notes should be linked next?',
        'zh-CN': '下一步应该关联哪些论文或笔记？',
    },
    'daily_title_prefix': {'en': 'Daily', 'zh-CN': '日志'},
    'daily_h1_prefix': {'en': 'Daily Log', 'zh-CN': '日志'},
    'daily_project_label': {'en': 'Project', 'zh-CN': '项目'},
    'daily_task_1': {'en': "Review today's objectives", 'zh-CN': '检查今天的目标'},
    'daily_task_2': {'en': 'Log research or engineering progress', 'zh-CN': '记录研究或工程进展'},
    'daily_task_3': {
        'en': 'Link new findings to `Experiments/`, `Results/`, or `Papers/` when they become durable',
        'zh-CN': '当新发现稳定后，将其关联到 `Experiments/`、`Results/` 或 `Papers/`',
    },
    'daily_initialized': {
        'en': 'Initialized automatically from project bootstrap.',
        'zh-CN': '由项目 bootstrap 自动初始化。',
    },
    'project_memory_title_prefix': {'en': 'Project Memory', 'zh-CN': '项目记忆'},
    'project_memory_task_1': {'en': 'Review imported repository structure.', 'zh-CN': '检查已导入的仓库结构。'},
    'project_memory_task_2': {'en': 'Populate current experiments and results.', 'zh-CN': '补充当前实验和结果。'},
    'project_memory_task_3': {
        'en': 'Start linking papers and durable project knowledge.',
        'zh-CN': '开始关联论文与可沉淀的项目知识。',
    },
    'project_memory_no_experiments': {'en': 'None recorded yet.', 'zh-CN': '暂无记录。'},
    'project_memory_initialized': {'en': 'Knowledge base initialized.', 'zh-CN': '知识库已初始化。'},
    'project_memory_bootstrap_completed': {
        'en': 'Bootstrap completed at {timestamp}.',
        'zh-CN': '已于 {timestamp} 完成 bootstrap。',
    },
    'summary': {'en': 'Summary', 'zh-CN': '摘要'},
    'changed_paths': {'en': 'Changed Paths', 'zh-CN': '变更路径'},
    'auto_sync_heading': {'en': 'Auto Sync {timestamp}', 'zh-CN': '自动同步 {timestamp}'},
    'scope': {'en': 'Scope', 'zh-CN': '范围'},
    'git_head': {'en': 'Git head', 'zh-CN': 'Git head'},
    'changed_file_count': {'en': 'Changed files', 'zh-CN': '变更文件数'},
    'category_summary': {'en': 'Categories', 'zh-CN': '分类'},
    'sample_paths': {'en': 'Sample paths', 'zh-CN': '样例路径'},
    'no_trackable_changes': {'en': 'No trackable changes', 'zh-CN': '无可追踪变更'},
    'sync_hub_bullet': {
        'en': 'Auto sync `{scope}` at {timestamp} recorded {count} changed files ({summary}). See [[{daily_ref}]].',
        'zh-CN': '自动同步 `{scope}` 于 {timestamp} 记录了 {count} 个变更文件（{summary}）。详见 [[{daily_ref}]]。',
    },
    'sync_time': {'en': 'Recent sync time', 'zh-CN': '最近同步时间'},
    'check_plan_changes': {
        'en': 'Review plan/TODO/README changes and synchronize `01-Plan.md`.',
        'zh-CN': '检查 plan/TODO/README 的变更，并同步更新 `01-Plan.md`。',
    },
    'record_experiment_changes': {
        'en': 'Record new training, inference, and config changes in `Archive/Auto-Sync/Experiments-Latest-Sync.md`.',
        'zh-CN': '将新的训练、推理和配置变更记录到 `Archive/Auto-Sync/Experiments-Latest-Sync.md`。',
    },
    'summarize_result_changes': {
        'en': 'Summarize new analysis, report, and result files in `Archive/Auto-Sync/Results-Latest-Sync.md`.',
        'zh-CN': '将新变更的分析、报告和结果文件总结到 `Archive/Auto-Sync/Results-Latest-Sync.md`。',
    },
    'review_writing_and_literature': {
        'en': 'Review writing and literature notes, and only promote stable content into `Writing/` or `Papers/`.',
        'zh-CN': '检查写作和文献相关笔记，只在内容稳定时再沉淀到 `Writing/` 或 `Papers/`。',
    },
    'check_engineering_impact': {
        'en': 'Check whether engineering-only code changes affect experiments or results, and write follow-up actions into `01-Plan.md` when needed.',
        'zh-CN': '检查纯工程代码变更是否会影响实验或结果，并在需要时把后续动作写入 `01-Plan.md`。',
    },
    'no_follow_up_tasks': {
        'en': 'Current repository changes do not require follow-up tasks.',
        'zh-CN': '当前仓库变更未检测到需要跟进的任务。',
    },
    'latest_experiment_sync': {'en': 'Latest Experiment Sync', 'zh-CN': '最新实验同步'},
    'latest_experiment_sync_summary_1': {
        'en': 'Auto sync captured {count} experiment-related paths.',
        'zh-CN': '自动同步捕获了 {count} 条与实验相关的路径。',
    },
    'latest_experiment_sync_summary_2': {
        'en': 'Review training, inference, config, or model changes and convert them into durable experiment notes.',
        'zh-CN': '请检查配置、训练、推理或模型改动，并将其转化为可持续维护的实验笔记。',
    },
    'latest_result_sync': {'en': 'Latest Result Sync', 'zh-CN': '最新结果同步'},
    'latest_result_sync_summary_1': {
        'en': 'Auto sync captured {count} result-related paths.',
        'zh-CN': '自动同步捕获了 {count} 条与结果相关的路径。',
    },
    'latest_result_sync_summary_2': {
        'en': 'Review analysis, reports, and outputs, and promote important findings into durable result notes.',
        'zh-CN': '请检查分析、报告和输出产物，并将重要发现沉淀为稳定的结果笔记。',
    },
    'sync_memory_experiment_line': {'en': '{timestamp}: touched `{path}`', 'zh-CN': '{timestamp}：涉及 `{path}`'},
    'sync_memory_result_line': {'en': '{timestamp}: touched `{path}`', 'zh-CN': '{timestamp}：涉及 `{path}`'},
    'sync_memory_no_results': {'en': 'No result changes recorded.', 'zh-CN': '暂无结果变更记录。'},
    'sync_memory_status_line': {
        'en': '{timestamp}: scope `{scope}`, git head `{head}`, changed files={count} ({summary}).',
        'zh-CN': '{timestamp}：范围 `{scope}`，git head `{head}`，变更文件数={count}（{summary}）。',
    },
}


@dataclass(frozen=True)
class ProjectBinding:
    project_id: str
    repo_root: Path
    vault_name: str
    vault_path: Path
    project_root: Path
    hub_note: str
    status: str
    auto_sync: bool
    archive_root: Path
    note_language: str


@dataclass(frozen=True)
class SyncContext:
    binding: ProjectBinding
    memory_path: Path
    project_title: str
    timestamp: str
    current_head: str
    last_synced_head: str
    changed_paths: tuple[str, ...]
    categorized: dict[str, list[str]]
    scope: str


def normalize_note_language(value: str | None) -> str | None:
    if not value:
        return None
    return NOTE_LANGUAGE_ALIASES.get(value.strip().lower())


def env_note_language() -> str | None:
    for key in NOTE_LANGUAGE_ENV_VARS:
        normalized = normalize_note_language(os.environ.get(key))
        if normalized:
            return normalized
    return None


def note_language_from_project_memory(repo_root: Path, project_id: str) -> str | None:
    memory_path = repo_root / '.claude' / 'project-memory' / f'{project_id}.md'
    frontmatter = parse_frontmatter(read_text(memory_path))
    return normalize_note_language(frontmatter.get('language'))


def resolve_note_language(
    repo_root: Path,
    project_id: str | None = None,
    entry: dict[str, Any] | None = None,
) -> str:
    if entry:
        normalized = normalize_note_language(str(entry.get('note_language', '')))
        if normalized:
            return normalized
    if project_id:
        normalized = note_language_from_project_memory(repo_root, project_id)
        if normalized:
            return normalized
    return env_note_language() or DEFAULT_NOTE_LANGUAGE


def resolve_bootstrap_note_language(value: str | None) -> str:
    return normalize_note_language(value) or env_note_language() or DEFAULT_NOTE_LANGUAGE


def text_value(note_language: str, key: str, **kwargs: Any) -> str:
    template = TEXT[key][note_language]
    return template.format(**kwargs)


def section_heading(section_key: str, note_language: str) -> str:
    return SECTION_LABELS[section_key][note_language]


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')


def slugify(value: str) -> str:
    slug = re.sub(r'[^A-Za-z0-9]+', '-', value).strip('-').lower()
    return slug or 'research-project'


def normalize_note_token(value: str) -> str:
    return re.sub(r'[^a-z0-9]+', '-', value.lower()).strip('-')


def token_set(value: str) -> set[str]:
    return {token for token in re.split(r'[^a-z0-9]+', value.lower()) if token}


def titleize_slug(slug: str) -> str:
    return ' '.join(part.capitalize() for part in slug.split('-'))


def find_repo_root(cwd: Path) -> Path:
    try:
        output = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], cwd=str(cwd), stderr=subprocess.DEVNULL)
        return Path(output.decode().strip())
    except Exception:
        cur = cwd.resolve()
        for candidate in [cur, *cur.parents]:
            if (candidate / '.git').exists():
                return candidate
        return cur


def registry_path(repo_root: Path) -> Path:
    return repo_root / '.claude' / 'project-memory' / 'registry.yaml'


def load_registry(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {'projects': {}}
    text = path.read_text(encoding='utf-8').strip()
    if not text:
        return {'projects': {}}
    data = json.loads(text)
    if 'projects' not in data or not isinstance(data['projects'], dict):
        data = {'projects': {}}
    return data


def save_registry(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def detect_project_features(repo_root: Path) -> dict[str, Any]:
    feature_checks = {
        '.git': (repo_root / '.git').exists(),
        'README.md': (repo_root / 'README.md').exists(),
        'docs/*.md': (repo_root / 'docs').exists(),
        'notes/*.md': (repo_root / 'notes').exists(),
        'plan/': (repo_root / 'plan').exists(),
        'results/': (repo_root / 'results').exists(),
        'outputs/': (repo_root / 'outputs').exists(),
        'src/': (repo_root / 'src').exists(),
        'scripts/': (repo_root / 'scripts').exists(),
    }
    config_hits = []
    for name in ['pyproject.toml', 'requirements.txt', 'environment.yml', 'configs', 'conf', 'Makefile']:
        if (repo_root / name).exists():
            config_hits.append(name)
    score = sum(1 for value in feature_checks.values() if value) + min(len(config_hits), 2)
    return {
        'score': score,
        'matched': [name for name, value in feature_checks.items() if value],
        'config_hits': config_hits,
        'is_candidate': score >= 3,
    }


def relative_note_path(target: Path, vault_path: Path) -> str:
    return str(target.relative_to(vault_path)).replace(os.sep, '/')


def should_ignore_relative_path(path: str) -> bool:
    parts = Path(path).parts
    return any(part in IGNORE_DIRS for part in parts)


def safe_walk(base: Path):
    for root, dirs, files in os.walk(base):
        dirs[:] = [name for name in dirs if name not in IGNORE_DIRS and not name.startswith('.DS_Store')]
        yield Path(root), dirs, files


def collect_files(repo_root: Path, extensions: set[str], limit: int = MAX_LIST_ITEMS) -> list[Path]:
    collected: list[Path] = []
    for root, _, files in safe_walk(repo_root):
        for file_name in files:
            path = root / file_name
            if path.suffix.lower() in extensions:
                collected.append(path)
                if len(collected) >= limit:
                    return sorted(collected)
    return sorted(collected)


def collect_markdown_sources(repo_root: Path) -> list[Path]:
    preferred = ['README.md', 'docs', 'notes', 'plan', 'plans', 'TODO.md', 'todo.md']
    result: list[Path] = []
    for name in preferred:
        path = repo_root / name
        if path.is_file() and path.suffix.lower() in DOC_EXTENSIONS:
            result.append(path)
        elif path.is_dir():
            for root, _, files in safe_walk(path):
                for file_name in files:
                    candidate = root / file_name
                    if candidate.suffix.lower() in DOC_EXTENSIONS:
                        result.append(candidate)
                        if len(result) >= MAX_LIST_ITEMS:
                            return sorted(result)
    if len(result) < MAX_LIST_ITEMS:
        seen = {path.resolve() for path in result}
        for path in collect_files(repo_root, DOC_EXTENSIONS, MAX_LIST_ITEMS):
            if path.resolve() not in seen:
                result.append(path)
                if len(result) >= MAX_LIST_ITEMS:
                    break
    return sorted(result)


def collect_result_files(repo_root: Path) -> list[Path]:
    result_dirs = ['results', 'outputs', 'reports', 'logs']
    result: list[Path] = []
    for name in result_dirs:
        path = repo_root / name
        if path.is_dir():
            for root, _, files in safe_walk(path):
                for file_name in files:
                    candidate = root / file_name
                    if candidate.suffix.lower() in RESULT_EXTENSIONS:
                        result.append(candidate)
                        if len(result) >= MAX_LIST_ITEMS:
                            return sorted(result)
    return sorted(result)


def top_level_dirs(repo_root: Path) -> list[str]:
    names: list[str] = []
    for child in sorted(repo_root.iterdir()):
        if child.name.startswith('.') or child.name in IGNORE_DIRS:
            continue
        if child.is_dir():
            names.append(child.name)
    return names[:20]


def key_entry_files(repo_root: Path) -> list[str]:
    candidates: list[str] = []
    names = ['README.md', 'pyproject.toml', 'requirements.txt', 'Makefile', 'run.py', 'train.py', 'main.py', 'setup.py']
    for name in names:
        if (repo_root / name).exists():
            candidates.append(name)
    for root, _, files in safe_walk(repo_root):
        if root == repo_root:
            continue
        for file_name in sorted(files):
            if file_name in {'train.py', 'run.py', 'main.py', 'analyze.py', 'evaluate.py'}:
                candidates.append(str((root / file_name).relative_to(repo_root)))
    deduped: list[str] = []
    for item in candidates:
        if item not in deduped:
            deduped.append(item)
    return deduped[:20]


def detect_language_hints(repo_root: Path) -> list[str]:
    hits: list[str] = []
    if (repo_root / 'pyproject.toml').exists() or list(repo_root.glob('*.py')) or (repo_root / 'src').exists():
        hits.append('Python')
    if list(repo_root.glob('*.ts')) or list(repo_root.glob('*.js')) or (repo_root / 'package.json').exists():
        hits.append('JavaScript/TypeScript')
    if (repo_root / 'Cargo.toml').exists():
        hits.append('Rust')
    if (repo_root / 'go.mod').exists():
        hits.append('Go')
    return hits or ['Unknown']


def build_source_inventory(repo_root: Path, note_language: str) -> str:
    docs = collect_markdown_sources(repo_root)
    results = collect_result_files(repo_root)
    code = collect_files(repo_root, CODE_EXTENSIONS, MAX_LIST_ITEMS)

    def render(paths: list[Path], label: str) -> str:
        if not paths:
            return f'## {label}\n\n- {text_value(note_language, "none_detected")}\n'
        lines = [f'## {label}', '']
        for path in paths:
            lines.append(f'- `{path.relative_to(repo_root)}`')
        return '\n'.join(lines) + '\n'

    header = [
        '---',
        'type: meta',
        f'title: {text_value(note_language, "source_inventory_title", repo_name=repo_root.name)}',
        f'project: {slugify(repo_root.name)}',
        f'language: {note_language}',
        f'updated: {now_iso()}',
        '---',
        '',
        f'# {text_value(note_language, "source_inventory_h1")}',
        '',
        text_value(note_language, 'source_inventory_imported_from', repo_root=repo_root),
        '',
    ]
    body = (
        render(docs, text_value(note_language, 'markdown_sources'))
        + '\n'
        + render(code, text_value(note_language, 'code_and_config_files'))
        + '\n'
        + render(results, text_value(note_language, 'result_and_report_files'))
    )
    return '\n'.join(header) + body


def build_codebase_overview(repo_root: Path, note_language: str) -> str:
    dirs = top_level_dirs(repo_root)
    entry_files = key_entry_files(repo_root)
    feature_info = detect_project_features(repo_root)
    languages = detect_language_hints(repo_root)
    lines = [
        '---',
        'type: meta',
        f'title: {text_value(note_language, "codebase_overview_title", repo_name=repo_root.name)}',
        f'project: {slugify(repo_root.name)}',
        f'language: {note_language}',
        f'updated: {now_iso()}',
        '---',
        '',
        f'# {text_value(note_language, "codebase_overview_h1")}',
        '',
        f'- **{text_value(note_language, "repository_root")}**: `{repo_root}`',
        f'- **{text_value(note_language, "detected_languages")}**: {", ".join(languages)}',
        f'- **{text_value(note_language, "research_project_score")}**: {feature_info["score"]}',
        f'- **{text_value(note_language, "matched_signals")}**: {", ".join(feature_info["matched"] or [text_value(note_language, "none")])}',
        '',
        f'## {text_value(note_language, "top_level_directories")}',
        '',
    ]
    if dirs:
        lines.extend(f'- `{name}`' for name in dirs)
    else:
        lines.append(f'- {text_value(note_language, "none")}')
    lines.extend(['', f'## {text_value(note_language, "key_entry_files")}', ''])
    if entry_files:
        lines.extend(f'- `{name}`' for name in entry_files)
    else:
        lines.append(f'- {text_value(note_language, "none")}')
    lines.extend([
        '',
        f'## {text_value(note_language, "suggested_knowledge_targets")}',
        '',
        f'- {text_value(note_language, "suggested_target_1")}',
        f'- {text_value(note_language, "suggested_target_2")}',
        f'- {text_value(note_language, "suggested_target_3")}',
    ])
    return '\n'.join(lines) + '\n'


def base_file(title: str, folder: str, note_type: str) -> str:
    return f'''filters:\n  and:\n    - 'project == "{{{{this.project}}}}"'\n    - 'type == "{note_type}"'\n\nproperties:\n  title:\n    displayName: "标题"\n  status:\n    displayName: "状态"\n  updated:\n    displayName: "更新时间"\n  file.path:\n    displayName: "路径"\n\nviews:\n  - type: table\n    name: "{title}"\n    filters:\n      and:\n        - 'file.inFolder("{folder}")'\n    order:\n      - title\n      - status\n      - updated\n      - file.path\n'''


def canvas_file(project_slug: str, title: str, note_language: str) -> str:
    return json.dumps(
        {
            'nodes': [
                {
                    'id': 'hub-node',
                    'type': 'text',
                    'x': 0,
                    'y': 0,
                    'width': 440,
                    'height': 220,
                    'text': (
                        f'# {title}\n\n'
                        f'{text_value(note_language, "project_label")}: [[00-Hub]]\n\n'
                        f'{text_value(note_language, "canvas_description")}'
                    ),
                },
                {
                    'id': 'plan-node',
                    'type': 'file',
                    'x': 520,
                    'y': -20,
                    'width': 320,
                    'height': 220,
                    'file': '../01-Plan.md'
                }
            ],
            'edges': [
                {
                    'id': 'edge-plan',
                    'fromNode': 'hub-node',
                    'fromSide': 'right',
                    'toNode': 'plan-node',
                    'toSide': 'left',
                    'toEnd': 'arrow',
                    'label': project_slug
                }
            ]
        },
        ensure_ascii=False,
        indent=2,
    ) + '\n'


def daily_note_path(project_root: Path) -> Path:
    return project_root / 'Daily' / (datetime.now().strftime('%Y-%m-%d') + '.md')


def hub_note(project_slug: str, project_title: str, note_language: str) -> str:
    today = datetime.now().strftime('%Y-%m-%d')
    return f'''---
type: project
title: {project_title}
project: {project_slug}
language: {note_language}
status: active
tags:
  - research/project
updated: {now_iso()}
---

# {project_title}

## {text_value(note_language, 'hub_mission_heading')}
- {text_value(note_language, 'hub_mission_body')}

## {text_value(note_language, 'hub_core_index')}
- [[01-Plan]]
- [[Daily/{today}|{text_value(note_language, 'today_daily_note')}]]
- [[Knowledge/Source-Inventory]]
- [[Knowledge/Codebase-Overview]]
- `Results/Reports/`

## {section_heading('recent_progress', note_language)}
- {text_value(note_language, 'hub_initialized', timestamp=now_iso())}

## {text_value(note_language, 'hub_folder_layout')}
- `Knowledge/`
- `Papers/`
- `Experiments/`
- `Results/`
- `Results/Reports/`
- `Writing/`
- `Daily/`
'''


def plan_note(project_slug: str, project_title: str, note_language: str) -> str:
    return f'''---
type: project
title: {text_value(note_language, 'plan_title_prefix')} - {project_title}
project: {project_slug}
language: {note_language}
status: active
updated: {now_iso()}
---

# {text_value(note_language, 'plan_h1')}

## {section_heading('active_goals', note_language)}
- {text_value(note_language, 'plan_goal_1')}
- {text_value(note_language, 'plan_goal_2')}

## {section_heading('active_tasks', note_language)}
- [ ] {text_value(note_language, 'plan_task_1')}
- [ ] {text_value(note_language, 'plan_task_2')}
- [ ] {text_value(note_language, 'plan_task_3')}

## {section_heading('open_questions', note_language)}
- {text_value(note_language, 'plan_question_1')}
- {text_value(note_language, 'plan_question_2')}
- {text_value(note_language, 'plan_question_3')}
'''


def daily_note(project_slug: str, project_title: str, note_language: str) -> str:
    today = datetime.now().strftime('%Y-%m-%d')
    return f'''---
type: daily
title: {text_value(note_language, 'daily_title_prefix')} - {today}
project: {project_slug}
language: {note_language}
status: active
updated: {now_iso()}
---

# {text_value(note_language, 'daily_h1_prefix')} - {today}

## {section_heading('focus', note_language)}
- {text_value(note_language, 'daily_project_label')}: [[00-Hub|{project_title}]]

## {section_heading('planned_tasks', note_language)}
- [ ] {text_value(note_language, 'daily_task_1')}
- [ ] {text_value(note_language, 'daily_task_2')}
- [ ] {text_value(note_language, 'daily_task_3')}

## {section_heading('notes', note_language)}
- {text_value(note_language, 'daily_initialized')}
'''


def project_memory(project_id: str, repo_root: Path, project_root: Path, hub_rel: str, note_language: str) -> str:
    head = get_git_head(repo_root)
    return f'''---
project_id: {project_id}
repo_root: {repo_root}
vault_root: {project_root}
hub_note: {hub_rel}
language: {note_language}
last_sync_at: {now_iso()}
last_synced_head: {head}
status: active
auto_sync: true
---

# {text_value(note_language, 'project_memory_title_prefix')}: {project_id}

## {section_heading('current_question', note_language)}
- TODO

## {section_heading('hypotheses', note_language)}
- TODO

## {section_heading('active_tasks', note_language)}
- {text_value(note_language, 'project_memory_task_1')}
- {text_value(note_language, 'project_memory_task_2')}
- {text_value(note_language, 'project_memory_task_3')}

## {section_heading('open_experiments', note_language)}
- {text_value(note_language, 'project_memory_no_experiments')}

## {section_heading('recent_results', note_language)}
- {text_value(note_language, 'project_memory_initialized')}

## {section_heading('recent_sync_status', note_language)}
- {text_value(note_language, 'project_memory_bootstrap_completed', timestamp=now_iso())}
'''


def get_git_head(repo_root: Path) -> str:
    try:
        output = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=str(repo_root), stderr=subprocess.DEVNULL)
        return output.decode().strip()
    except Exception:
        return 'unknown'


def ensure_note(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_text(content, encoding='utf-8')


def bootstrap_project(
    repo_root: Path,
    vault_path: Path,
    project_name: str | None = None,
    force: bool = False,
    note_language: str | None = None,
) -> dict[str, Any]:
    project_slug = slugify(project_name or repo_root.name)
    project_title = project_name or titleize_slug(project_slug)
    resolved_language = resolve_bootstrap_note_language(note_language)
    project_root = vault_path / 'Research' / project_slug
    archive_root = vault_path / 'Archive'
    project_root.mkdir(parents=True, exist_ok=True)
    for rel in ['Knowledge', 'Papers', 'Experiments', 'Results', 'Results/Reports', 'Writing', 'Daily', 'Archive']:
        (project_root / rel).mkdir(parents=True, exist_ok=True)

    ensure_note(project_root / '00-Hub.md', hub_note(project_slug, project_title, resolved_language))
    ensure_note(project_root / '01-Plan.md', plan_note(project_slug, project_title, resolved_language))
    ensure_note(daily_note_path(project_root), daily_note(project_slug, project_title, resolved_language))
    ensure_note(project_root / 'Knowledge' / 'Source-Inventory.md', build_source_inventory(repo_root, resolved_language))
    ensure_note(project_root / 'Knowledge' / 'Codebase-Overview.md', build_codebase_overview(repo_root, resolved_language))

    reg_path = registry_path(repo_root)
    registry = load_registry(reg_path)
    entry = {
        'project_id': project_slug,
        'repo_roots': [str(repo_root)],
        'vault_name': os.environ.get('OBSIDIAN_VAULT_NAME', vault_path.name),
        'vault_root': str(project_root),
        'hub_note': relative_note_path(project_root / '00-Hub.md', vault_path),
        'status': 'active',
        'auto_sync': True,
        'note_language': resolved_language,
        'created_at': now_iso(),
        'updated_at': now_iso(),
        'archive_root': str(archive_root),
    }
    registry['projects'][project_slug] = entry
    save_registry(reg_path, registry)

    memory_path = repo_root / '.claude' / 'project-memory' / f'{project_slug}.md'
    if force or not memory_path.exists():
        memory_path.parent.mkdir(parents=True, exist_ok=True)
        memory_path.write_text(
            project_memory(project_slug, repo_root, project_root, entry['hub_note'], resolved_language),
            encoding='utf-8',
        )

    return {
        'project_id': project_slug,
        'repo_root': str(repo_root),
        'vault_root': str(project_root),
        'hub_note': entry['hub_note'],
        'memory_file': str(memory_path),
        'note_language': resolved_language,
    }


def detect(repo_root: Path) -> dict[str, Any]:
    reg_path = registry_path(repo_root)
    registry = load_registry(reg_path)
    matched = None
    for project_id, entry in registry.get('projects', {}).items():
        for root in entry.get('repo_roots', []):
            try:
                if Path(root).resolve() == repo_root.resolve():
                    matched = {'project_id': project_id, **entry}
                    break
            except Exception:
                continue
        if matched:
            break
    feature_info = detect_project_features(repo_root)
    return {
        'repo_root': str(repo_root),
        'registry_path': str(reg_path),
        'is_registered': matched is not None,
        'project': matched,
        'resolved_note_language': resolve_note_language(
            repo_root,
            matched['project_id'] if matched else None,
            matched,
        ),
        'candidate': feature_info,
    }


def resolve_binding(repo_root: Path, project_id: str | None = None) -> ProjectBinding:
    registry = load_registry(registry_path(repo_root))
    if not registry.get('projects'):
        raise SystemExit('No registered projects found in .claude/project-memory/registry.yaml')

    if project_id is None:
        detected = detect(repo_root)
        if detected.get('project'):
            project_id = detected['project']['project_id']
        elif len(registry['projects']) == 1:
            project_id = next(iter(registry['projects']))
        else:
            raise SystemExit('Multiple projects registered; pass --project-id')

    entry = registry['projects'].get(project_id)
    if not entry:
        raise SystemExit(f'Project {project_id!r} not found in registry')

    project_root = Path(entry['vault_root'])
    vault_path = project_root.parent.parent
    return ProjectBinding(
        project_id=project_id,
        repo_root=repo_root,
        vault_name=entry.get('vault_name', vault_path.name),
        vault_path=vault_path,
        project_root=project_root,
        hub_note=entry.get('hub_note', relative_note_path(project_root / '00-Hub.md', vault_path)),
        status=entry.get('status', 'active'),
        auto_sync=bool(entry.get('auto_sync', True)),
        archive_root=Path(entry.get('archive_root') or (vault_path / 'Archive')),
        note_language=resolve_note_language(repo_root, project_id, entry),
    )


def lifecycle(repo_root: Path, mode: str, project_id: str | None = None) -> dict[str, Any]:
    reg_path = registry_path(repo_root)
    registry = load_registry(reg_path)
    binding = resolve_binding(repo_root, project_id)
    entry = registry['projects'][binding.project_id]
    memory_path = repo_root / '.claude' / 'project-memory' / f'{binding.project_id}.md'

    if mode == 'detach':
        entry['auto_sync'] = False
        entry['status'] = 'detached'
        entry['repo_roots'] = []
        entry['updated_at'] = now_iso()
        save_registry(reg_path, registry)
        return {'mode': mode, 'project_id': binding.project_id, 'registry_path': str(reg_path)}

    if mode == 'archive':
        archive_root = binding.archive_root
        archive_root.mkdir(parents=True, exist_ok=True)
        archive_target = archive_root / binding.project_root.name
        if archive_target.exists():
            archive_target = archive_root / f'{binding.project_root.name}-{datetime.now().strftime("%Y%m%d-%H%M%S")}'
        if binding.project_root.exists():
            shutil.move(str(binding.project_root), str(archive_target))
        entry['status'] = 'archived'
        entry['auto_sync'] = False
        entry['repo_roots'] = []
        entry['vault_root'] = str(archive_target)
        entry['hub_note'] = str(Path('Archive') / archive_target.name / '00-Hub.md').replace(os.sep, '/')
        entry['updated_at'] = now_iso()
        save_registry(reg_path, registry)
        return {'mode': mode, 'project_id': binding.project_id, 'archive_target': str(archive_target)}

    if mode == 'purge':
        if binding.project_root.exists():
            shutil.rmtree(binding.project_root)
        if memory_path.exists():
            memory_path.unlink()
        del registry['projects'][binding.project_id]
        save_registry(reg_path, registry)
        return {'mode': mode, 'project_id': binding.project_id, 'purged': True}

    raise SystemExit(f'Unsupported mode: {mode}')


def read_text(path: Path, default: str = '') -> str:
    return path.read_text(encoding='utf-8') if path.exists() else default


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + '\n', encoding='utf-8')


def format_frontmatter_value(value: Any) -> str:
    if isinstance(value, bool):
        return 'true' if value else 'false'
    return str(value)


def set_frontmatter_value(content: str, key: str, value: Any) -> str:
    formatted = format_frontmatter_value(value)
    if content.startswith('---\n'):
        end = content.find('\n---\n', 4)
        if end != -1:
            frontmatter = content[4:end]
            body = content[end + 5:]
            pattern = re.compile(rf'^{re.escape(key)}:\s*.*$', re.M)
            if pattern.search(frontmatter):
                frontmatter = pattern.sub(f'{key}: {formatted}', frontmatter)
            else:
                frontmatter = frontmatter.rstrip() + f'\n{key}: {formatted}'
            return f'---\n{frontmatter}\n---\n{body.lstrip()}'
    return f'---\n{key}: {formatted}\n---\n\n{content.lstrip()}'


def parse_frontmatter(content: str) -> dict[str, str]:
    if not content.startswith('---\n'):
        return {}
    end = content.find('\n---\n', 4)
    if end == -1:
        return {}
    data: dict[str, str] = {}
    for line in content[4:end].splitlines():
        if ':' not in line or line.strip().startswith('- '):
            continue
        key, value = line.split(':', 1)
        data[key.strip()] = value.strip()
    return data


def section_heading_candidates(section_key: str) -> list[str]:
    values = [SECTION_LABELS[section_key][language] for language in SUPPORTED_NOTE_LANGUAGES]
    deduped: list[str] = []
    for value in values:
        if value not in deduped:
            deduped.append(value)
    return deduped


def section_heading_pattern(section_key: str) -> str:
    return '|'.join(re.escape(item) for item in section_heading_candidates(section_key))


def upsert_section(content: str, section_key: str, body: str, note_language: str) -> str:
    section_header = f'## {section_heading(section_key, note_language)}'
    body_text = body.strip() or '- None'
    pattern = re.compile(rf'(^##\s+(?:{section_heading_pattern(section_key)})\s*\n)(.*?)(?=^##\s+|\Z)', re.M | re.S)
    replacement = f'{section_header}\n{body_text}\n\n'
    if pattern.search(content):
        return pattern.sub(replacement, content, count=1).rstrip() + '\n'
    return content.rstrip() + f'\n\n{replacement}'


def get_section_body(content: str, section_key: str) -> str:
    pattern = re.compile(rf'^##\s+(?:{section_heading_pattern(section_key)})\s*\n(.*?)(?=^##\s+|\Z)', re.M | re.S)
    match = pattern.search(content)
    return match.group(1).strip() if match else ''


def bullet_lines_from_section(content: str, section_key: str) -> list[str]:
    section = get_section_body(content, section_key)
    return [line.strip() for line in section.splitlines() if line.strip().startswith('- ')]


def prepend_bullets(
    content: str,
    section_key: str,
    new_lines: list[str],
    note_language: str,
    limit: int = RECENT_BULLET_LIMIT,
) -> str:
    existing = bullet_lines_from_section(content, section_key)
    merged: list[str] = []
    for line in [*new_lines, *existing]:
        if line not in merged:
            merged.append(line)
    return upsert_section(content, section_key, '\n'.join(merged[:limit]), note_language)


def append_block(content: str, section_key: str, block: str, note_language: str, limit: int = 4) -> str:
    existing = get_section_body(content, section_key)
    blocks = [piece.strip() for piece in re.split(r'\n(?=###\s+)', existing) if piece.strip()]
    merged = [block.strip(), *blocks]
    return upsert_section(content, section_key, '\n\n'.join(merged[:limit]), note_language)


def render_bullets(items: list[str], empty: str = '- None recorded.') -> str:
    if not items:
        return empty
    return '\n'.join(items)


def limited_paths(paths: list[str], limit: int = MAX_SYNC_PATHS) -> list[str]:
    return paths[:limit]


def project_note_ref(path: Path, project_root: Path) -> str:
    rel = path.relative_to(project_root).as_posix()
    return rel[:-3] if rel.endswith('.md') else rel


def note_folder_for_kind(kind: str) -> Path:
    folder = NOTE_KIND_FOLDERS.get(kind)
    if not folder:
        raise SystemExit(f'Unsupported note kind: {kind}')
    return Path(folder)


def list_kind_notes(project_root: Path, kind: str) -> list[Path]:
    folder = project_root / note_folder_for_kind(kind)
    if not folder.exists():
        return []
    return sorted(path for path in folder.rglob('*.md') if path.is_file())


def index_note_paths(project_root: Path) -> list[Path]:
    result: list[Path] = []
    for rel in INDEX_NOTE_REL_PATHS:
        path = project_root / rel
        if path.exists():
            result.append(path)
    return result


def unique_stem_in_project(project_root: Path, target: Path) -> bool:
    stem = target.stem
    matches = list(project_root.rglob(f'{stem}.md'))
    return len(matches) == 1


def search_note_candidates(project_root: Path, kind: str, query: str, limit: int = 5) -> list[Path]:
    notes = list_kind_notes(project_root, kind)
    if not notes:
        return []

    raw_query = query.strip()
    query_path = project_root / raw_query
    if query_path.exists() and query_path.suffix.lower() == '.md':
        return [query_path]

    if raw_query.endswith('.md'):
        rel_match = project_root / raw_query
        if rel_match.exists():
            return [rel_match]

    query_ref = raw_query[:-3] if raw_query.endswith('.md') else raw_query
    query_norm = normalize_note_token(query_ref)
    query_tokens = token_set(query_ref)
    scored: list[tuple[tuple[int, int, int], Path]] = []
    for note in notes:
        ref = project_note_ref(note, project_root)
        stem_norm = normalize_note_token(note.stem)
        ref_norm = normalize_note_token(ref)
        stem_tokens = token_set(note.stem)
        ref_tokens = token_set(ref)
        score: tuple[int, int, int] | None = None
        if ref == query_ref or note.stem == raw_query:
            score = (0, len(ref), len(note.stem))
        elif ref_norm == query_norm or stem_norm == query_norm:
            score = (1, len(ref_norm), len(stem_norm))
        elif query_norm and query_norm in stem_norm:
            score = (2, len(stem_norm), len(ref_norm))
        elif query_norm and query_norm in ref_norm:
            score = (3, len(ref_norm), len(stem_norm))
        elif query_tokens:
            overlap = len(query_tokens & (stem_tokens | ref_tokens))
            if overlap:
                score = (4, -overlap, len(ref_norm))
        if score is not None:
            scored.append((score, note))
    scored.sort(key=lambda item: (item[0], project_note_ref(item[1], project_root)))
    return [note for _, note in scored[:limit]]


def query_context(repo_root: Path, kind: str, query: str | None = None, project_id: str | None = None) -> dict[str, Any]:
    binding = resolve_binding(repo_root, project_id)
    project_root = binding.project_root
    memory_path = repo_root / '.claude' / 'project-memory' / f'{binding.project_id}.md'
    today_path = daily_note_path(project_root)
    context_paths: list[Path] = []

    def add(path: Path) -> None:
        if path.exists() and path not in context_paths:
            context_paths.append(path)

    add(memory_path)
    add(project_root / '00-Hub.md')
    add(project_root / '01-Plan.md')

    candidate_paths: list[Path] = []
    primary: Path | None = None

    if kind == 'broad':
        add(project_root / 'Knowledge' / 'Source-Inventory.md')
        add(project_root / 'Knowledge' / 'Codebase-Overview.md')
    elif kind == 'next-step':
        add(today_path)
    elif kind in NOTE_KIND_FOLDERS:
        if kind == 'daily':
            add(today_path)
            candidate_paths = [today_path] if today_path.exists() else []
        elif query:
            candidate_paths = search_note_candidates(project_root, kind, query)
            if candidate_paths:
                primary = candidate_paths[0]
                add(primary)
        elif kind == 'knowledge':
            add(project_root / 'Knowledge' / 'Source-Inventory.md')
            add(project_root / 'Knowledge' / 'Codebase-Overview.md')
            candidate_paths = [path for path in context_paths if path.parent.name == 'Knowledge']
    else:
        raise SystemExit(f'Unsupported query kind: {kind}')

    return {
        'project_id': binding.project_id,
        'kind': kind,
        'query': query or '',
        'primary_note': str(primary) if primary else '',
        'candidate_notes': [str(path) for path in candidate_paths],
        'recommended_reads': [str(path) for path in context_paths],
    }


def find_canonical_note(repo_root: Path, kind: str, query: str, project_id: str | None = None) -> dict[str, Any]:
    if kind not in NOTE_KIND_FOLDERS or kind == 'daily':
        raise SystemExit('find-canonical-note supports only knowledge, paper, experiment, result, or writing')
    if not query.strip():
        raise SystemExit('find-canonical-note requires a non-empty --query')

    binding = resolve_binding(repo_root, project_id)
    project_root = binding.project_root
    candidates = search_note_candidates(project_root, kind, query)
    primary = candidates[0] if candidates else None

    recommended_reads: list[str] = []
    for path in [
        repo_root / '.claude' / 'project-memory' / f'{binding.project_id}.md',
        project_root / '00-Hub.md',
        project_root / '01-Plan.md',
        primary,
    ]:
        if path and path.exists():
            text = str(path)
            if text not in recommended_reads:
                recommended_reads.append(text)

    return {
        'project_id': binding.project_id,
        'kind': kind,
        'query': query,
        'recommended_canonical_note': str(primary) if primary else '',
        'candidate_notes': [str(path) for path in candidates],
        'recommended_reads': recommended_reads,
        'guidance': (
            'Use this as a candidate finder only. The agent must still decide whether to update '
            'the recommended note, create a new one, or merge into another durable note.'
        ),
    }


def resolve_project_note(project_root: Path, note: str) -> Path:
    candidate = (project_root / note).resolve()
    if candidate.exists() and candidate.suffix.lower() == '.md':
        return candidate
    if note.endswith('.md'):
        raise SystemExit(f'Note not found: {note}')
    candidate_md = (project_root / f'{note}.md').resolve()
    if candidate_md.exists():
        return candidate_md
    raise SystemExit(f'Note not found: {note}')


def archive_target_for_note(binding: ProjectBinding, note_path: Path) -> Path:
    rel = note_path.relative_to(binding.project_root)
    target = binding.project_root / 'Archive' / rel
    if target.exists():
        target = target.with_name(f'{target.stem}-{datetime.now().strftime("%Y%m%d-%H%M%S")}{target.suffix}')
    return target


def replace_note_links(content: str, old_path: Path, project_root: Path, new_path: Path | None = None) -> str:
    old_ref = project_note_ref(old_path, project_root)
    new_ref = project_note_ref(new_path, project_root) if new_path else None
    refs = [old_ref]
    if unique_stem_in_project(project_root, old_path):
        refs.append(old_path.stem)

    def replace_variant(text: str, source_ref: str) -> str:
        escaped = re.escape(source_ref)
        if new_ref is None:
            text = re.sub(
                rf'\[\[{escaped}\|([^\]]+)\]\]',
                lambda m: f'`{m.group(1)} (deleted)`',
                text,
            )
            text = re.sub(
                rf'\[\[{escaped}\]\]',
                f'`{Path(source_ref).name} (deleted)`',
                text,
            )
            return text
        text = re.sub(
            rf'\[\[{escaped}\|([^\]]+)\]\]',
            lambda m: f'[[{new_ref}|{m.group(1)}]]',
            text,
        )
        text = re.sub(
            rf'\[\[{escaped}\]\]',
            f'[[{new_ref}]]',
            text,
        )
        return text

    updated = content
    for source_ref in refs:
        updated = replace_variant(updated, source_ref)
    return updated


def repair_index_links(binding: ProjectBinding, old_path: Path, new_path: Path | None = None) -> list[str]:
    touched: list[str] = []
    for path in index_note_paths(binding.project_root):
        original = read_text(path)
        updated = replace_note_links(original, old_path, binding.project_root, new_path)
        if updated != original:
            write_text(path, updated)
            touched.append(str(path))
    return touched


def note_lifecycle(repo_root: Path, mode: str, note: str, dest: str | None = None, project_id: str | None = None) -> dict[str, Any]:
    binding = resolve_binding(repo_root, project_id)
    note_path = resolve_project_note(binding.project_root, note)
    if not note_path.is_relative_to(binding.project_root):
        raise SystemExit('Note path must stay inside the project root')
    archive_root = (binding.project_root / 'Archive').resolve()
    if note_path.is_relative_to(archive_root) and mode != 'rename':
        raise SystemExit('Note is already under Archive/')

    if mode == 'archive':
        target = archive_target_for_note(binding, note_path)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(note_path), str(target))
        repaired = repair_index_links(binding, note_path, target)
        return {
            'mode': mode,
            'note': str(note_path),
            'target': str(target),
            'repaired_index_notes': repaired,
        }

    if mode == 'purge':
        repaired = repair_index_links(binding, note_path, None)
        note_path.unlink()
        return {
            'mode': mode,
            'note': str(note_path),
            'purged': True,
            'repaired_index_notes': repaired,
        }

    if mode == 'rename':
        if not dest:
            raise SystemExit('Rename requires --dest')
        target = (binding.project_root / dest).resolve()
        if target.suffix.lower() != '.md':
            target = target.with_suffix('.md')
        if not str(target).startswith(str(binding.project_root.resolve())):
            raise SystemExit('Rename target must stay inside the project root')
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(note_path), str(target))
        repaired = repair_index_links(binding, note_path, target)
        return {
            'mode': mode,
            'note': str(note_path),
            'target': str(target),
            'repaired_index_notes': repaired,
        }

    raise SystemExit(f'Unsupported note lifecycle mode: {mode}')


def git_output(repo_root: Path, args: list[str]) -> str:
    try:
        output = subprocess.check_output(['git', *args], cwd=str(repo_root), stderr=subprocess.DEVNULL)
        return output.decode()
    except Exception:
        return ''


def git_lines(repo_root: Path, args: list[str]) -> list[str]:
    output = git_output(repo_root, args)
    return [line.rstrip() for line in output.splitlines() if line.strip()]


def parse_status_path(line: str) -> str:
    payload = line[3:] if len(line) > 3 else line
    if ' -> ' in payload:
        payload = payload.split(' -> ', 1)[1]
    return payload.strip()


def collect_repo_changes(repo_root: Path, last_synced_head: str) -> list[str]:
    paths: list[str] = []
    seen: set[str] = set()

    if last_synced_head and last_synced_head != 'unknown':
        for path in git_lines(repo_root, ['diff', '--name-only', f'{last_synced_head}..HEAD']):
            if not should_ignore_relative_path(path) and path not in seen:
                paths.append(path)
                seen.add(path)

    for path in [parse_status_path(line) for line in git_lines(repo_root, ['status', '--short'])]:
        if not path or should_ignore_relative_path(path) or path in seen:
            continue
        paths.append(path)
        seen.add(path)

    return sorted(paths)


def classify_path(path: str) -> set[str]:
    lowered = path.lower()
    top = Path(path).parts[0] if Path(path).parts else ''
    categories: set[str] = set()

    if top in {'plan', 'plans', 'docs'} or lowered in {'readme.md', 'todo.md', 'todo.txt'}:
        categories.update({'plan', 'writing'})
    if top in {'outputs', 'results', 'reports', 'logs'} or 'report' in lowered or 'metrics' in lowered:
        categories.add('results')
    if top in {'run', 'scripts'} or lowered.startswith('src/trainer_module') or lowered.startswith('src/model_module'):
        categories.add('experiments')
    if lowered.startswith('src/analysis_module') or 'analysis' in lowered or 'eda' in lowered:
        categories.add('results')
    if lowered.startswith('src/data_module') or lowered.startswith('src/model_module') or lowered.startswith('src/trainer_module'):
        categories.add('experiments')
    if any(token in Path(path).name.lower() for token in ['train', 'inference', 'infer', 'eval', 'experiment']):
        categories.add('experiments')
    if 'paper' in lowered or 'citation' in lowered or top in {'papers', 'literature'}:
        categories.update({'literature', 'writing'})
    if top in {'meeting', 'meetings'}:
        categories.add('meetings')
    if top in {'src', 'tests', 'test'}:
        categories.add('engineering')
    if not categories:
        categories.add('engineering')
    return categories


def categorize_paths(paths: list[str]) -> dict[str, list[str]]:
    categorized: dict[str, list[str]] = {topic: [] for topic in [*SYNC_TOPICS, 'engineering']}
    for path in paths:
        for category in classify_path(path):
            categorized.setdefault(category, []).append(path)
    for key in categorized:
        categorized[key] = sorted(dict.fromkeys(categorized[key]))
    return categorized


def summarize_categories(categorized: dict[str, list[str]]) -> list[str]:
    ordered = ['plan', 'experiments', 'results', 'literature', 'writing', 'meetings', 'engineering']
    return [f'{name}={len(categorized.get(name, []))}' for name in ordered if categorized.get(name)]


def selected_topics(scope: str, categorized: dict[str, list[str]]) -> set[str]:
    if scope == 'all':
        return set(SYNC_TOPICS)
    if scope in SYNC_TOPICS:
        return {scope}
    if scope == 'daily':
        return set()
    auto = {topic for topic in SYNC_TOPICS if categorized.get(topic)}
    if any(categorized.get(topic) for topic in ('experiments', 'results', 'writing', 'literature', 'engineering')):
        auto.add('plan')
    return auto


def repo_change_bullets(categorized: dict[str, list[str]], note_language: str) -> list[str]:
    bullets: list[str] = []
    if categorized.get('plan'):
        bullets.append(f'- {text_value(note_language, "check_plan_changes")}')
    if categorized.get('experiments'):
        bullets.append(f'- {text_value(note_language, "record_experiment_changes")}')
    if categorized.get('results'):
        bullets.append(f'- {text_value(note_language, "summarize_result_changes")}')
    if categorized.get('literature') or categorized.get('writing'):
        bullets.append(f'- {text_value(note_language, "review_writing_and_literature")}')
    if categorized.get('engineering'):
        bullets.append(f'- {text_value(note_language, "check_engineering_impact")}')
    if not bullets:
        bullets.append(f'- {text_value(note_language, "no_follow_up_tasks")}')
    return bullets


def topic_note(
    title: str,
    note_type: str,
    project_id: str,
    summary: list[str],
    paths: list[str],
    note_language: str,
    extra_heading: str | None = None,
    extra_lines: list[str] | None = None,
) -> str:
    sections = [
        '---',
        f'type: {note_type}',
        f'title: {title}',
        f'project: {project_id}',
        f'language: {note_language}',
        'status: active',
        f'updated: {now_iso()}',
        '---',
        '',
        f'# {title}',
        '',
        f'## {text_value(note_language, "summary")}',
        '',
        *summary,
        '',
        f'## {text_value(note_language, "changed_paths")}',
        '',
        *(f'- `{path}`' for path in limited_paths(paths)),
    ]
    if extra_heading and extra_lines:
        sections.extend(['', f'## {extra_heading}', '', *extra_lines])
    return '\n'.join(sections) + '\n'


def build_sync_context(binding: ProjectBinding, scope: str) -> SyncContext:
    memory_path = binding.repo_root / '.claude' / 'project-memory' / f'{binding.project_id}.md'
    memory_text = read_text(memory_path)
    frontmatter = parse_frontmatter(memory_text)
    last_synced_head = frontmatter.get('last_synced_head', 'unknown')
    changed_paths = tuple(collect_repo_changes(binding.repo_root, last_synced_head))
    categorized = categorize_paths(list(changed_paths))
    return SyncContext(
        binding=binding,
        memory_path=memory_path,
        project_title=titleize_slug(binding.project_id),
        timestamp=now_iso(),
        current_head=get_git_head(binding.repo_root),
        last_synced_head=last_synced_head,
        changed_paths=changed_paths,
        categorized=categorized,
        scope=scope,
    )


def refresh_meta(ctx: SyncContext) -> None:
    write_text(
        ctx.binding.project_root / 'Knowledge' / 'Source-Inventory.md',
        build_source_inventory(ctx.binding.repo_root, ctx.binding.note_language),
    )
    write_text(
        ctx.binding.project_root / 'Knowledge' / 'Codebase-Overview.md',
        build_codebase_overview(ctx.binding.repo_root, ctx.binding.note_language),
    )


def sync_daily(ctx: SyncContext) -> Path:
    daily_path = daily_note_path(ctx.binding.project_root)
    if not daily_path.exists():
        write_text(daily_path, daily_note(ctx.binding.project_id, ctx.project_title, ctx.binding.note_language))
    content = read_text(daily_path)
    content = set_frontmatter_value(content, 'language', ctx.binding.note_language)
    content = set_frontmatter_value(content, 'updated', ctx.timestamp)
    category_summary = ', '.join(summarize_categories(ctx.categorized)) or text_value(ctx.binding.note_language, 'none')
    sample_paths = [f'  - `{path}`' for path in limited_paths(list(ctx.changed_paths), 10)] or [f'  - {text_value(ctx.binding.note_language, "none")}']
    block = '\n'.join([
        f'### {text_value(ctx.binding.note_language, "auto_sync_heading", timestamp=ctx.timestamp)}',
        f'- {text_value(ctx.binding.note_language, "scope")}: `{ctx.scope}`',
        f'- {text_value(ctx.binding.note_language, "git_head")}: `{ctx.current_head}`',
        f'- {text_value(ctx.binding.note_language, "changed_file_count")}: {len(ctx.changed_paths)}',
        f'- {text_value(ctx.binding.note_language, "category_summary")}: {category_summary}',
        f'- {text_value(ctx.binding.note_language, "sample_paths")}:',
        *sample_paths,
    ])
    content = append_block(content, 'sync_updates', block, ctx.binding.note_language)
    write_text(daily_path, content)
    return daily_path


def sync_hub(ctx: SyncContext, daily_path: Path) -> None:
    hub_path = ctx.binding.project_root / '00-Hub.md'
    content = read_text(hub_path, hub_note(ctx.binding.project_id, ctx.project_title, ctx.binding.note_language))
    content = set_frontmatter_value(content, 'language', ctx.binding.note_language)
    content = set_frontmatter_value(content, 'updated', ctx.timestamp)
    summary = ', '.join(summarize_categories(ctx.categorized)) or text_value(ctx.binding.note_language, 'no_trackable_changes')
    bullet = '- ' + text_value(
        ctx.binding.note_language,
        'sync_hub_bullet',
        scope=ctx.scope,
        timestamp=ctx.timestamp,
        count=len(ctx.changed_paths),
        summary=summary,
        daily_ref=daily_path.relative_to(ctx.binding.project_root).as_posix(),
    )
    content = prepend_bullets(content, 'recent_progress', [bullet], ctx.binding.note_language)
    write_text(hub_path, content)


def sync_plan(ctx: SyncContext) -> None:
    plan_path = ctx.binding.project_root / '01-Plan.md'
    content = read_text(plan_path, plan_note(ctx.binding.project_id, ctx.project_title, ctx.binding.note_language))
    content = set_frontmatter_value(content, 'language', ctx.binding.note_language)
    content = set_frontmatter_value(content, 'updated', ctx.timestamp)
    signal_lines = [
        f'- {text_value(ctx.binding.note_language, "sync_time")}: {ctx.timestamp}',
        f'- {text_value(ctx.binding.note_language, "git_head")}: `{ctx.current_head}`',
        f'- {text_value(ctx.binding.note_language, "changed_file_count")}: {len(ctx.changed_paths)}',
        f'- {text_value(ctx.binding.note_language, "category_summary")}: {", ".join(summarize_categories(ctx.categorized)) or text_value(ctx.binding.note_language, "none")}',
    ]
    content = upsert_section(content, 'repository_signals', '\n'.join(signal_lines), ctx.binding.note_language)
    content = upsert_section(
        content,
        'sync_queue',
        render_bullets(repo_change_bullets(ctx.categorized, ctx.binding.note_language)),
        ctx.binding.note_language,
    )
    write_text(plan_path, content)


def sync_experiments(ctx: SyncContext) -> None:
    paths = ctx.categorized.get('experiments', [])
    if not paths:
        return
    write_text(
        ctx.binding.project_root / 'Archive' / 'Auto-Sync' / 'Experiments-Latest-Sync.md',
        topic_note(
            title=text_value(ctx.binding.note_language, 'latest_experiment_sync'),
            note_type='experiment',
            project_id=ctx.binding.project_id,
            summary=[
                f'- {text_value(ctx.binding.note_language, "latest_experiment_sync_summary_1", count=len(paths))}',
                f'- {text_value(ctx.binding.note_language, "latest_experiment_sync_summary_2")}',
            ],
            paths=paths,
            note_language=ctx.binding.note_language,
        ),
    )


def sync_results(ctx: SyncContext) -> None:
    paths = ctx.categorized.get('results', [])
    if not paths:
        return
    write_text(
        ctx.binding.project_root / 'Archive' / 'Auto-Sync' / 'Results-Latest-Sync.md',
        topic_note(
            title=text_value(ctx.binding.note_language, 'latest_result_sync'),
            note_type='result',
            project_id=ctx.binding.project_id,
            summary=[
                f'- {text_value(ctx.binding.note_language, "latest_result_sync_summary_1", count=len(paths))}',
                f'- {text_value(ctx.binding.note_language, "latest_result_sync_summary_2")}',
            ],
            paths=paths,
            note_language=ctx.binding.note_language,
        ),
    )


def sync_writing(ctx: SyncContext) -> None:
    return


def sync_project_memory(ctx: SyncContext) -> None:
    content = read_text(
        ctx.memory_path,
        project_memory(
            ctx.binding.project_id,
            ctx.binding.repo_root,
            ctx.binding.project_root,
            ctx.binding.hub_note,
            ctx.binding.note_language,
        ),
    )
    for key, value in {
        'repo_root': ctx.binding.repo_root,
        'vault_root': ctx.binding.project_root,
        'hub_note': ctx.binding.hub_note,
        'language': ctx.binding.note_language,
        'last_sync_at': ctx.timestamp,
        'last_synced_head': ctx.current_head,
        'status': 'active',
        'auto_sync': True,
    }.items():
        content = set_frontmatter_value(content, key, value)

    existing_tasks = bullet_lines_from_section(content, 'active_tasks')
    generated_tasks = [line.replace('- [ ] ', '- ').replace('- ', '- ') for line in repo_change_bullets(ctx.categorized, ctx.binding.note_language)]
    merged_tasks: list[str] = []
    for line in [*existing_tasks, *generated_tasks]:
        if line not in merged_tasks:
            merged_tasks.append(line)
    content = upsert_section(
        content,
        'active_tasks',
        render_bullets(merged_tasks[:RECENT_BULLET_LIMIT]),
        ctx.binding.note_language,
    )

    experiment_lines = [
        f'- {text_value(ctx.binding.note_language, "sync_memory_experiment_line", timestamp=ctx.timestamp, path=path)}'
        for path in limited_paths(ctx.categorized.get('experiments', []), 8)
    ]
    result_lines = [
        f'- {text_value(ctx.binding.note_language, "sync_memory_result_line", timestamp=ctx.timestamp, path=path)}'
        for path in limited_paths(ctx.categorized.get('results', []), 8)
    ]
    content = upsert_section(
        content,
        'open_experiments',
        render_bullets(experiment_lines, f'- {text_value(ctx.binding.note_language, "project_memory_no_experiments")}'),
        ctx.binding.note_language,
    )
    content = upsert_section(
        content,
        'recent_results',
        render_bullets(result_lines, f'- {text_value(ctx.binding.note_language, "sync_memory_no_results")}'),
        ctx.binding.note_language,
    )

    summary = ', '.join(summarize_categories(ctx.categorized)) or text_value(ctx.binding.note_language, 'no_trackable_changes')
    sync_line = '- ' + text_value(
        ctx.binding.note_language,
        'sync_memory_status_line',
        timestamp=ctx.timestamp,
        scope=ctx.scope,
        head=ctx.current_head,
        count=len(ctx.changed_paths),
        summary=summary,
    )
    content = prepend_bullets(content, 'recent_sync_status', [sync_line], ctx.binding.note_language)
    write_text(ctx.memory_path, content)


def update_registry_after_sync(ctx: SyncContext) -> None:
    path = registry_path(ctx.binding.repo_root)
    registry = load_registry(path)
    entry = registry['projects'][ctx.binding.project_id]
    entry['updated_at'] = ctx.timestamp
    entry['status'] = 'active'
    entry['auto_sync'] = True
    save_registry(path, registry)


def sync_project(repo_root: Path, scope: str, project_id: str | None = None) -> dict[str, Any]:
    binding = resolve_binding(repo_root, project_id)
    if binding.status == 'archived':
        raise SystemExit('Project is archived; rebuild or rebind before syncing')

    ctx = build_sync_context(binding, scope)
    refresh_meta(ctx)
    daily_path = sync_daily(ctx)
    sync_hub(ctx, daily_path)
    sync_project_memory(ctx)

    selected = selected_topics(scope, ctx.categorized)
    if scope in {'all', 'plan'} or 'plan' in selected:
        sync_plan(ctx)
    if scope in {'all', 'experiments'} or 'experiments' in selected:
        sync_experiments(ctx)
    if scope in {'all', 'results'} or 'results' in selected:
        sync_results(ctx)
    if scope in {'all', 'literature', 'writing'} or {'literature', 'writing'} & selected:
        sync_writing(ctx)

    update_registry_after_sync(ctx)
    return {
        'project_id': ctx.binding.project_id,
        'scope': scope,
        'project_root': str(ctx.binding.project_root),
        'daily_note': str(daily_path),
        'changed_files': len(ctx.changed_paths),
        'categories': {key: len(value) for key, value in ctx.categorized.items() if value},
        'selected_topics': sorted(selected),
        'sample_paths': limited_paths(list(ctx.changed_paths), 12),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Bootstrap and manage Obsidian project knowledge bases.')
    sub = parser.add_subparsers(dest='cmd', required=True)

    detect_parser = sub.add_parser('detect')
    detect_parser.add_argument('--cwd', default='.')

    boot_parser = sub.add_parser('bootstrap')
    boot_parser.add_argument('--cwd', default='.')
    boot_parser.add_argument('--vault-path', default=os.environ.get('OBSIDIAN_VAULT_PATH', ''))
    boot_parser.add_argument('--project-name', default='')
    boot_parser.add_argument('--note-language', default='')
    boot_parser.add_argument('--force', action='store_true')

    life_parser = sub.add_parser('lifecycle')
    life_parser.add_argument('--cwd', default='.')
    life_parser.add_argument('--mode', required=True, choices=['detach', 'archive', 'purge'])
    life_parser.add_argument('--project-id', default='')

    sync_parser = sub.add_parser('sync')
    sync_parser.add_argument('--cwd', default='.')
    sync_parser.add_argument('--scope', default='auto', choices=['auto', 'daily', 'plan', 'literature', 'experiments', 'results', 'all'])
    sync_parser.add_argument('--project-id', default='')

    query_parser = sub.add_parser('query-context')
    query_parser.add_argument('--cwd', default='.')
    query_parser.add_argument('--kind', required=True, choices=['broad', 'next-step', 'knowledge', 'paper', 'experiment', 'result', 'writing', 'daily'])
    query_parser.add_argument('--query', default='')
    query_parser.add_argument('--project-id', default='')

    canonical_parser = sub.add_parser('find-canonical-note')
    canonical_parser.add_argument('--cwd', default='.')
    canonical_parser.add_argument('--kind', required=True, choices=['knowledge', 'paper', 'experiment', 'result', 'writing'])
    canonical_parser.add_argument('--query', required=True)
    canonical_parser.add_argument('--project-id', default='')

    note_parser = sub.add_parser('note-lifecycle')
    note_parser.add_argument('--cwd', default='.')
    note_parser.add_argument('--mode', required=True, choices=['archive', 'purge', 'rename'])
    note_parser.add_argument('--note', required=True, help='Project-relative path to the markdown note')
    note_parser.add_argument('--dest', default='', help='Destination path for rename, relative to the project root')
    note_parser.add_argument('--project-id', default='')

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    repo_root = find_repo_root(Path(args.cwd).resolve())

    if args.cmd == 'detect':
        print(json.dumps(detect(repo_root), ensure_ascii=False, indent=2))
        return

    if args.cmd == 'bootstrap':
        if not args.vault_path:
            raise SystemExit('Missing vault path. Pass --vault-path or set OBSIDIAN_VAULT_PATH.')
        result = bootstrap_project(
            repo_root,
            Path(args.vault_path).expanduser().resolve(),
            args.project_name or None,
            args.force,
            args.note_language or None,
        )
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    if args.cmd == 'lifecycle':
        result = lifecycle(repo_root, args.mode, args.project_id or None)
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    if args.cmd == 'sync':
        result = sync_project(repo_root, args.scope, args.project_id or None)
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    if args.cmd == 'query-context':
        result = query_context(repo_root, args.kind, args.query or None, args.project_id or None)
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    if args.cmd == 'find-canonical-note':
        result = find_canonical_note(repo_root, args.kind, args.query, args.project_id or None)
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    if args.cmd == 'note-lifecycle':
        result = note_lifecycle(repo_root, args.mode, args.note, args.dest or None, args.project_id or None)
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return


if __name__ == '__main__':
    main()
