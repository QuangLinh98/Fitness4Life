package fpt.aptech.fitnessgoalservice.models;


public enum GoalType {
    //Giảm cân
    WEIGHT_LOSS {
        public double calculateTargetCalories(double tdee) {
            return tdee - 500;   //Giảm 500 calo
        }
    },
    //Tăng cân
    WEIGHT_GAIN{
        public double calculateTargetCalories(double tdee) {
            return tdee + 500;
        }
    },
    //Tăng cơ
    MUSCLE_GAIN{
        public double calculateTargetCalories(double tdee) {
            return tdee + 300;
        }
    },
    //Giảm mỡ
    FAT_LOSS{
        public double calculateTargetCalories(double tdee) {
            return tdee - 300;
        }
    },
    //ENDURANCE_IMPROVEMENT,   //Cải thiện sức bền
    //HEART_HEALTH,            //Tim mạch

    //Duy trì cân nặng
    MAINTENANCE{
        public double calculateTargetCalories(double tdee) {
            return tdee;  //Duy trì không thay đổi
        }
    };

    public abstract double calculateTargetCalories(double tdee);
}