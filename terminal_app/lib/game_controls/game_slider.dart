import "package:flutter/material.dart";
import "dart:ui" as ui;
import "dart:math";
import "game_colors.dart";
import "game_command_widget.dart";
import "game_radial.dart";

class GameSlider extends StatefulWidget implements GameCommand
{
	//GameSlider({Key key, this.value = 40, this.min = 0, this.max = 200}) : super(key: key);
	GameSlider.make(this.issueCommand, this.taskType, Map params) : value = params['min'], min = params['min'], max = params['max'];

	GameSlider.fromRadial(GameRadial radial) :
		issueCommand = radial.issueCommand,
		taskType = radial.taskType,
		value = radial.value, min = radial.min, max = radial.max;

	final int value;
	final int min;
	final int max;
	final String taskType;
	final IssueCommandCallback issueCommand;

	@override
	_GameSliderState createState() => new _GameSliderState(value, min, max);
}

class _GameSliderState extends State<GameSlider> with SingleTickerProviderStateMixin
{
	int value = 0;
	final int minValue;
	final int maxValue;
	
	AnimationController _controller;
	Animation<double> _valueAnimation;

	_GameSliderState(this.value, this.minValue, this.maxValue);
	int targetValue = 0;
	
	void valueChanged(double v)
	{
		int target = (minValue + (v * 4).round() * ((maxValue-minValue)/4)).round();
		if(targetValue == target)
		{
			return;
		}
		targetValue = target;
		_valueAnimation = new Tween<double>
		(
			begin: value.toDouble(),
			end: targetValue.toDouble()
		).animate(_controller);
	
		_controller
			..value = 0.0
			//..fling(velocity: 0.01);
			..animateTo(1.0, curve:Curves.easeInOut);


		// setState(()
		// {
		// 	value = (minValue + v * (maxValue-minValue)).round();
		// });
	}

	void commitValueChange()
	{
		widget.issueCommand(widget.taskType, targetValue);
	}

	initState() 
	{
    	super.initState();
		_controller = new AnimationController(duration: const Duration(milliseconds:200), vsync: this);
		_controller.addListener(()
		{
			setState(()
			{
				value = _valueAnimation.value.round();
			});
		});
	}

	@override
	Widget build(BuildContext context) 
	{
		return new Container(
			child:new Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					new Container(
						// margin:
						child:new Text(value.toString(), 
							style: const TextStyle(color: const Color.fromARGB(255, 167, 230, 237), 
							fontFamily: "Inconsolata", 
							fontWeight: FontWeight.bold, 
							fontSize: 18.0, 
							decoration: TextDecoration.none)
						)
					),
					new Container(
						margin: const EdgeInsets.symmetric(vertical: 32.0),
						child: new Row(children:<Widget>[
							new Container(
								margin: new EdgeInsets.only(right: 10.0), 
								child: new Text(
									minValue.toString(), 
									style: const TextStyle(color: const Color.fromARGB(69, 167, 230, 237), 
									fontFamily: "Inconsolata", 
									fontWeight: FontWeight.bold, 
									fontSize: 14.0, 
									decoration: TextDecoration.none)
								)
							),
							new Expanded(child: new NotchedSlider((value-minValue)/(maxValue-minValue), valueChanged, commitValueChange)),
							new Container(
								margin: new EdgeInsets.only(left: 10.0), 
								child:new Text(maxValue.toString(), 
									style: const TextStyle(color: const Color.fromARGB(69, 167, 230, 237), 
									fontFamily: "Inconsolata", 
									fontWeight: FontWeight.bold, 
									fontSize: 14.0, 
									decoration: TextDecoration.none)
								)
							),
						])
					)
				]
			)
		);
	}
}

typedef void ValueChangeCallback(double value);

class NotchedSlider extends StatefulWidget 
{
	NotchedSlider(this.value, this.valueChanged, this.commitValue, {Key key}) : super(key: key);

	final double value;
	final ValueChangeCallback valueChanged;
	final VoidCallback commitValue;

	@override
	_NotchedSliderState createState() => new _NotchedSliderState();
}

class _NotchedSliderState extends State<NotchedSlider>
{
	_NotchedSliderState();

	void dragStart(DragStartDetails details)
	{
		RenderBox ro = context.findRenderObject();
		if(ro == null)
		{
			return;
		}
		if(ro == null)
		{
			return;
		}
		Offset local = ro.globalToLocal(details.globalPosition);
		widget.valueChanged(min(1.0, max(0.0, local.dx/context.size.width)));
	}

	void dragUpdate(DragUpdateDetails details)
	{
		//context.size
		RenderBox ro = context.findRenderObject();
		if(ro == null)
		{
			return;
		}
		Offset local = ro.globalToLocal(details.globalPosition);
		widget.valueChanged(min(1.0, max(0.0, local.dx/context.size.width)));
	}

	void dragEnd(DragEndDetails details)
	{
		widget.commitValue();
	}
	
	@override
	Widget build(BuildContext context) 
	{
		return new GestureDetector(
			onHorizontalDragStart: dragStart,
			onHorizontalDragUpdate: dragUpdate,
			onHorizontalDragEnd: dragEnd,
			child: new Container(
				child:new GameSliderNotches(widget.value)
			)
		);
	}
}

class GameSliderNotches extends LeafRenderObjectWidget
{
	final double value;

	GameSliderNotches(this.value,
		{
			Key key
		}): super(key: key);

	@override
	RenderObject createRenderObject(BuildContext context) 
	{
		return new GameSliderNotchesRenderObject(value);
	}

	@override
	void updateRenderObject(BuildContext context, covariant GameSliderNotchesRenderObject renderObject)
	{
		renderObject..value = value;
	}
}

class GameSliderNotchesRenderObject extends RenderBox
{
	double _value;

	GameSliderNotchesRenderObject(double value)
	{
		this.value = value;
	}

	@override
	bool get sizedByParent => true;
	
	@override
	bool hitTestSelf(Offset screenOffset) => true;

	@override
	void performResize() 
	{
		size = new Size(constraints.constrainWidth(), 30.0);
	}
/* 
	@override
	void performLayout()
	{
		super.performLayout();
		// final double detailsTextMaxWidth = size.width - Padding*2 - DetailPaddingLeft*2.0;

		// _timeParagraph.layout(new ui.ParagraphConstraints(width: detailsTextMaxWidth/2.0));

		// // Calculate actual (to the glyph) width consumed by the delivery time label.
		// List<ui.TextBox> boxes = _timeParagraph.getBoxesForRange(0, _deliveryTimeLabel.length);
		// _actualTimeWidth = boxes.last.right-boxes.first.left;

		// // Use that to calculate available remaining space for the title.
		// _nameParagraph.layout(new ui.ParagraphConstraints(width: detailsTextMaxWidth - _actualTimeWidth));

		// _descriptionParagraph.layout(new ui.ParagraphConstraints(width: detailsTextMaxWidth));
	}
*/
	@override
	void paint(PaintingContext context, Offset offset)
	{
		final Canvas canvas = context.canvas;
		const double notchWidth = 10.0;
		const double notchIdealPadding = 10.0;
		int numNotches = (size.width / (notchWidth+notchIdealPadding)).floor();
		double spacing = (size.width - numNotches*notchWidth)/max(1, (numNotches-1));

		double dx = 0.0;
		Size notchSize = new Size(notchWidth, size.height);
		int notchesHighlit = (value * numNotches).round();
		for(int i = 0; i < numNotches; i++)
		{
    		final RRect rrect = new RRect.fromRectAndRadius(new Offset(offset.dx+dx, offset.dy) & notchSize, const Radius.circular(2.0));
			canvas.drawRRect(rrect, new ui.Paint()..color = i < notchesHighlit ? GameColors.highValueContent : GameColors.lowValueContent);
			dx += notchWidth + spacing;
		}
	}

	double get value
	{
		return _value;
	}

	set value(double v)
	{
		if(_value == v)
		{
			return;
		}
		_value = v;

		markNeedsLayout();
		markNeedsPaint();
	}
}