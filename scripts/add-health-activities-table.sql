-- Create health_activities table
CREATE TABLE IF NOT EXISTS public.health_activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  activity_type TEXT NOT NULL CHECK (activity_type IN ('workout', 'meditation', 'medication', 'doctor_appointment', 'therapy_session', 'water_intake', 'sleep', 'custom')),
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  all_day BOOLEAN DEFAULT FALSE,
  recurring BOOLEAN DEFAULT FALSE,
  recurrence_pattern TEXT, -- JSON string with recurrence details
  reminder_time TIMESTAMP WITH TIME ZONE,
  reminder_sent BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS for health_activities
ALTER TABLE public.health_activities ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for health_activities
CREATE POLICY "Users can view their own health activities" 
  ON public.health_activities 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own health activities" 
  ON public.health_activities 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own health activities" 
  ON public.health_activities 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own health activities" 
  ON public.health_activities 
  FOR DELETE USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_health_activities_user_id ON public.health_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_health_activities_start_time ON public.health_activities(start_time);
CREATE INDEX IF NOT EXISTS idx_health_activities_activity_type ON public.health_activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_health_activities_reminder_time ON public.health_activities(reminder_time);

-- Create function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = now();
   RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to update updated_at on record change
CREATE TRIGGER update_health_activities_updated_at
BEFORE UPDATE ON public.health_activities
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column(); 