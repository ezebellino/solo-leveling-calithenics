"""Initial player module schema baseline."""

from alembic import op
import sqlalchemy as sa


revision = "20260504_01"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("alias", sa.String(length=80), nullable=False),
        sa.Column("avatar_url", sa.String(length=500), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=True),
        sa.Column("rank", sa.String(length=32), nullable=False),
        sa.Column("stage_index", sa.Integer(), nullable=False),
        sa.Column("stage_title", sa.String(length=64), nullable=False),
        sa.Column("stage_goal", sa.Text(), nullable=False),
        sa.Column("stage_frequency", sa.String(length=120), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )

    op.create_table(
        "inventory_items",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("code", sa.String(length=50), nullable=False),
        sa.Column("name", sa.String(length=80), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "code", name="uq_inventory_item_user_code"),
    )

    op.create_table(
        "player_progress",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("level", sa.Integer(), nullable=False),
        sa.Column("current_xp", sa.Integer(), nullable=False),
        sa.Column("next_level_xp", sa.Integer(), nullable=False),
        sa.Column("streak_days", sa.Integer(), nullable=False),
        sa.Column("completed_days", sa.Integer(), nullable=False),
        sa.Column("shadow_army", sa.Integer(), nullable=False),
        sa.Column("strength", sa.Integer(), nullable=False),
        sa.Column("agility", sa.Integer(), nullable=False),
        sa.Column("endurance", sa.Integer(), nullable=False),
        sa.Column("discipline", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id"),
    )

    op.create_table(
        "daily_quests",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("quest_date", sa.Date(), nullable=False),
        sa.Column("title", sa.String(length=120), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("xp_reward", sa.Integer(), nullable=False),
        sa.Column("progress", sa.Integer(), nullable=False),
        sa.Column("target", sa.Integer(), nullable=False),
        sa.Column("is_special", sa.Boolean(), nullable=False),
        sa.Column("is_completed", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )


def downgrade() -> None:
    op.drop_table("daily_quests")
    op.drop_table("player_progress")
    op.drop_table("inventory_items")
    op.drop_table("users")
