/*
 * Copyright 2023 elementary, Inc. <https://elementary.io>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Gala.WindowSwitcherIcon : Clutter.Actor {
    private const int WRAPPER_BORDER_RADIUS = 3;

    public Meta.Window window { get; construct; }

    private WindowIcon icon;
    private Clutter.Canvas canvas;

    private bool _selected = false;
    public bool selected {
        get {
            return _selected;
        }
        set {
            _selected = value;
            canvas.invalidate ();
        }
    }

    private float _scale_factor = 1.0f;
    public float scale_factor {
        get {
            return _scale_factor;
        }
        set {
            _scale_factor = value;
            canvas.scale_factor = _scale_factor;

            update_size ();
            canvas.invalidate ();
        }
    }

    public WindowSwitcherIcon (Meta.Window window, int icon_size, float scale_factor) {
        Object (window: window);

        icon = new WindowIcon (window, InternalUtils.scale_to_int (icon_size, scale_factor));
        icon.add_constraint (new Clutter.AlignConstraint (this, Clutter.AlignAxis.BOTH, 0.5f));
        add_child (icon);

        canvas = new Clutter.Canvas ();
        canvas.draw.connect (draw_background);
        set_content (canvas);

        reactive = true;

        this.scale_factor = scale_factor;
    }

    private void update_size () {
        var indicator_size = InternalUtils.scale_to_int (
            (WindowSwitcher.ICON_SIZE + WindowSwitcher.WRAPPER_PADDING * 2),
            scale_factor
        );
        set_size (indicator_size, indicator_size);
        canvas.set_size (indicator_size, indicator_size);
    }

    private bool draw_background (Cairo.Context ctx, int width, int height) {
        ctx.save ();
        ctx.set_operator (Cairo.Operator.CLEAR);
        ctx.paint ();
        ctx.clip ();
        ctx.reset_clip ();

        if (selected) {
            // draw rect
            var rgba = InternalUtils.get_theme_accent_color ();
            ctx.set_source_rgba (
                rgba.red,
                rgba.green,
                rgba.blue,
                rgba.alpha
            );
            var rect_radius = InternalUtils.scale_to_int (WRAPPER_BORDER_RADIUS, scale_factor);
            Drawing.Utilities.cairo_rounded_rectangle (ctx, 0, 0, width, height, rect_radius);
            ctx.set_operator (Cairo.Operator.SOURCE);
            ctx.fill ();

            ctx.restore ();
        }

        return true;
    }
}
