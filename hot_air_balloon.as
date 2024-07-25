const float pi = 3.14159f;
int forceid = 0;
int air_forceid;
vector3 checkpos1, checkpos2, checkpos3, checkpos4;
vector3 airpos;
array<int> upforceids, inflateforceids;
float temp = 0.5f;
float temp_old = 0.0f;
bool deactivated = false;


void main()
{
    for (int node = 36; node < 516; node++)
    {
        forceid = game.getFreeForceNextId();
        upforceids.insertLast(forceid);
        game.pushMessage(
            MSG_SIM_ADD_FREEFORCE_REQUESTED, {
                {"id", forceid },
                {"type", FREEFORCETYPE_CONSTANT },
                {"base_actor", thisActor.getInstanceId() },
                {"base_node", node },
                {"force_const_direction", vector3(0, 1, 0) },
                {"force_magnitude", 10.0f }
            }
        );
    }
    for (int node = 36; node < 516; node++)
    {
        forceid = game.getFreeForceNextId();
        inflateforceids.insertLast(forceid);
        game.pushMessage(
            MSG_SIM_ADD_FREEFORCE_REQUESTED, {
                {"id", forceid },
                {"type", FREEFORCETYPE_TOWARDS_NODE },
                {"base_actor", thisActor.getInstanceId() },
                {"base_node", node },
                {"force_magnitude", -20.0f },
                {"target_actor", thisActor.getInstanceId() },
                {"target_node", 516 }
            }
        );
    }
    air_forceid = game.getFreeForceNextId();
    game.pushMessage(
        MSG_SIM_ADD_FREEFORCE_REQUESTED, {
            {"id", air_forceid },
            {"type", FREEFORCETYPE_TOWARDS_COORDS },
            {"base_actor", thisActor.getInstanceId() },
            {"base_node", 516 },
            {"force_magnitude", 0.0f },
            {"target_coords", vector3(0, 0, 0) }
        }
    );
}


void frameStep(float dt)
{
    if (thisActor != null)
    {
        if (thisActor.getTruckState() == 0)
        {
            deactivated = false;

            checkpos1 = thisActor.getNodePosition(299);
            checkpos2 = thisActor.getNodePosition(381);
            checkpos3 = thisActor.getNodePosition(415);
            checkpos4 = thisActor.getNodePosition(429);

            airpos = (checkpos1+checkpos2+checkpos3+checkpos4)/4;

            game.pushMessage(
                MSG_SIM_MODIFY_FREEFORCE_REQUESTED, {
                    {"id", air_forceid },
                    {"type", FREEFORCETYPE_TOWARDS_COORDS },
                    {"base_actor", thisActor.getInstanceId() },
                    {"base_node", 516 },
                    {"force_magnitude", 80.0f },
                    {"target_coords", airpos }
                }
            );

            if (inputs.isKeyDownEffective(KC_F1))
            {
                temp += (1.0f - sin((temp / 2.0f) * pi)) * (dt);
            }
            if (inputs.isKeyDownEffective(KC_F2))
            {
                temp -= (1.0f - cos((temp / 2.0f) * pi)) * (dt);
            }

            if (temp > 1.0f) {temp = 1.0f;}
            else if (temp < 0.0f) {temp = 0.0f;}

            if (temp_old != temp)
            {
                for (int node = 36; node < 516; node++)
                {
                    game.pushMessage(
                        MSG_SIM_MODIFY_FREEFORCE_REQUESTED, {
                            {"id", upforceids[(node - 36)] },
                            {"type", FREEFORCETYPE_CONSTANT },
                            {"base_actor", thisActor.getInstanceId() },
                            {"base_node", node },
                            {"force_const_direction", vector3(0, 1, 0) },
                            {"force_magnitude", 20.0f*temp }
                        }
                    );

                    game.pushMessage(
                        MSG_SIM_MODIFY_FREEFORCE_REQUESTED, {
                            {"id", inflateforceids[(node - 36)] },
                            {"type", FREEFORCETYPE_TOWARDS_NODE },
                            {"base_actor", thisActor.getInstanceId() },
                            {"base_node", node },
                            {"force_magnitude", -80.0f*temp },
                            {"target_actor", thisActor.getInstanceId() },
                            {"target_node", 516 }
                        }
                    );
                }
            }
        }
        else if (not deactivated)
        {
            game.pushMessage(
                MSG_SIM_MODIFY_FREEFORCE_REQUESTED, {
                    {"id", air_forceid },
                    {"type", FREEFORCETYPE_TOWARDS_COORDS },
                    {"base_actor", thisActor.getInstanceId() },
                    {"base_node", 516 },
                    {"force_magnitude", 0.0f },
                    {"target_coords", vector3(0, 0, 0) }
                }
            );

            for (int node = 36; node < 516; node++)
            {
                game.pushMessage(
                    MSG_SIM_MODIFY_FREEFORCE_REQUESTED, {
                        {"id", upforceids[(node - 36)] },
                        {"type", FREEFORCETYPE_CONSTANT },
                        {"base_actor", thisActor.getInstanceId() },
                        {"base_node", node },
                        {"force_const_direction", vector3(0, 1, 0) },
                        {"force_magnitude", 0.0f }
                    }
                );

                game.pushMessage(
                    MSG_SIM_MODIFY_FREEFORCE_REQUESTED, {
                        {"id", inflateforceids[(node - 36)] },
                        {"type", FREEFORCETYPE_TOWARDS_NODE },
                        {"base_actor", thisActor.getInstanceId() },
                        {"base_node", node },
                        {"force_magnitude", 0.0f },
                        {"target_actor", thisActor.getInstanceId() },
                        {"target_node", 516 }
                    }
                );
            }
        }
        deactivated = true;
    }
}
