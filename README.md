# event-manager
My solution to the Event Manager Project for The Odin Project

## Overview
Most of this project consisted of following a tutorial which showed how to use the Google Civicinfo API to get information about legislators based on a person's zipcode. Therefore most of this code was not created by me.

It was really interesting to look through the documentation and see how these APIs can be used and play around with the functions in irb.

The assignments that I did on my own are the following:

- Create cleaned_phone_number() method. This takes a string input and then outputs the phone number in the standard (012) 345-6789 format.

- Create get_peak_hours() method. This takes the contents, accesses the date registered column, then using a reduce enumerable keeps a tally of the registrations in each hour of the day.

- Create get_peak_days() method. This takes the contents, accesses the date registered column, and also uses a reduce enumerable to tally up the registrations per day of the week. The assignment recommended using Date#wday but I preferred to use strftime("%A") as wday returns the number of the day of the week, which can be confusing based on whether Sunday or Monday is the first day of the week where you live. It seemed like outputting the actual name of the day would be safer.