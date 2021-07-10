import "dart:math";
import "command_tasks.dart";
import "replace_widget_tasks.dart";

class ListCornerRadius extends CommandTask
{
	int _cornerRadius = 0;

	Map serialize()
	{
		return CommandTask.makeRadial(this, 0, 60);
	}

	void complete(int value, String code)
	{
		_cornerRadius = value;
		if(!hasLineOfInterest)
		{
			findLineOfInterest(code, "LIST_CORNER_RADIUS");
		}
	}

	String getIssueCommand(int value)
	{
		return "SET LIST CORNER RADIUS TO $value";
	}
	
	String apply(String code)
	{
		code = code.replaceAll("LIST_CORNER_RADIUS", _cornerRadius.toString() + ".0");
		return code;
	}

	String taskType()
	{
		return "ListRadius";
	}

	String taskLabel()
	{
		return "Set List Corner Radius";
	}

	bool doesAutoApply()
	{
		return true;
	}

	void tryToIssue(List<IssuedTask> currentQueue)
	{
		Random rand = new Random();
		switch(rand.nextInt(3))
		{
			case 0:
				currentQueue.add(new IssuedTask()..task = this
													..value = 0);
				break;
			case 1:
				currentQueue.add(new IssuedTask()..task = this
													..value = 15);
				break;
			case 2:
				currentQueue.add(new IssuedTask()..task = this
													..value = 60);
				break;
		}
	}
}

class CarouselCornerRadius extends CommandTask
{
	int _cornerRadius = 0;

	Map serialize()
	{
		return CommandTask.makeRadial(this, 0, 30);
	}

	void complete(int value, String code)
	{
		_cornerRadius = value;
		if(!hasLineOfInterest)
		{
			findLineOfInterest(code, "CAROUSEL_CORNER_RADIUS");
		}
	}
	
	String getIssueCommand(int value)
	{
		return "SET CAROUSEL CORNER RADIUS TO $value";
	}

	String apply(String code)
	{
		code = code.replaceAll("CAROUSEL_CORNER_RADIUS", _cornerRadius.toString() + ".0");
		return code;
	}

	String taskType()
	{
		return "CarouselRadius";
	}

	String taskLabel()
	{
		return "Set Carousel Corner Radius";
	}

	bool doesAutoApply()
	{
		return true;
	}

	void tryToIssue(List<IssuedTask> currentQueue)
	{
		// We can only set the corner radius if the styling of the carousel has been set.
		int index = currentQueue.indexWhere((IssuedTask t)
		{	
			return t.task is ShowFeaturedCarousel;
		});
		if(index == -1)
		{
			return;
		}
		Random rand = new Random();
		switch(rand.nextInt(3))
		{
			case 0:
				currentQueue.add(new IssuedTask()..task = this
													..value = 8);
				break;
			case 1:
				currentQueue.add(new IssuedTask()..task = this
													..value = 15);
				break;
			case 2:
				currentQueue.add(new IssuedTask()..task = this
													..value = 30);
				break;
		}
	}
}